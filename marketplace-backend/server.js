const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const axios = require('axios');
require('dotenv').config();
console.log('>>> 🔥 GEMINI_KEY configurada:', process.env.GEMINI_API_KEY ? 'SÍ ✅' : 'NO ❌');

const { GoogleGenerativeAI } = require('@google/generative-ai');
const sharp = require('sharp');
const fs = require('fs');

// ==== ========================================================
// 🔥 FIREBASE ADMIN
// ============================================================
const admin = require('firebase-admin');
const { cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

try {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    admin.initializeApp({
         credential: cert(serviceAccount),
    });
    console.log('>>> 🔥 Firebase Admin inicializado correctamente');
} catch (error) {
    console.error('>>> ❌ Error al inicializar Firebase Admin:', error.message);
    console.log('>>> ⚠️ Las notificaciones push no funcionarán');
}

const app = express();
const port = 3000;

// 🔥 WEBSOCKET
const http = require('http');
const WebSocket = require('ws');
const Redis = require('ioredis');

// 🔥 REDIS PUB/SUB
let redisPub = null;
let redisSub = null;
let redisDisponible = false;

if (process.env.REDIS_URL) {
    try {
        redisPub = new Redis(process.env.REDIS_URL, {
            maxRetriesPerRequest: null,
            enableReadyCheck: false,
        });
        redisSub = new Redis(process.env.REDIS_URL, {
            maxRetriesPerRequest: null,
            enableReadyCheck: false,
        });

        redisPub.on('connect', () => {
            console.log('>>> 🔴 Redis Pub conectado');
            redisDisponible = true;
        });
        redisPub.on('error', (e) => {
            console.log('>>> ❌ Redis Pub error:', e.message);
            redisDisponible = false;
        });
        redisSub.on('connect', () => {
            console.log('>>> 🔴 Redis Sub conectado');
        });
        redisSub.on('error', (e) => {
            console.log('>>> ❌ Redis Sub error:', e.message);
        });

        // 🔥 ESCUCHAR EVENTOS DE OTRAS RÉPLICAS
        redisSub.on('message', (channel, message) => {
            try {
                const payload = JSON.parse(message);
                const conversacionId = channel.replace('conv:', '');
                // Solo entregar a clientes locales (sin re-publicar)
                entregarLocalmente(conversacionId, payload);
            } catch (e) {
                console.log('>>> ❌ Error parseando mensaje de Redis:', e.message);
            }
        });

        // 🔥 SUSCRIBIRSE AL CANAL GLOBAL
        redisSub.subscribe('ws:eventos', (err) => {
            if (err) console.log('>>> ❌ Error suscribiendo a Redis:', err.message);
            else console.log('>>> 🔴 Suscrito a canal ws:eventos');
        });
    } catch (e) {
        console.log('>>> ⚠️ Redis no disponible, modo 1 réplica:', e.message);
    }
} else {
    console.log('>>> ⚠️ REDIS_URL no configurada, modo 1 réplica');
}
// 🔥 USUARIOS EN LÍNEA (usuario_id → timestamp de última actividad)
const usuariosEnLinea = new Map();
const USUARIO_TIMEOUT_MS = 60 * 1000;

setInterval(() => {
    const ahora = Date.now();
    for (const [uid, ts] of usuariosEnLinea.entries()) {
        if (ahora - ts > USUARIO_TIMEOUT_MS) {
            usuariosEnLinea.delete(uid);
            console.log(`>>> 🟢 Usuario ${uid} OFFLINE por inactividad`);
        }
    }
}, 30000);

// 🔥 NOTIFICAR A LAS SALAS QUE UN USUARIO CAMBIÓ DE ESTADO
function broadcastPresencia(usuarioId, enLinea) {
    for (const [convId, sala] of salas.entries()) {
        for (const ws of sala) {
            if (ws.usuarioId !== usuarioId && ws.readyState === WebSocket.OPEN) {
                try {
                    ws.send(JSON.stringify({
                        tipo: 'presencia',
                        usuario_id: usuarioId,
                        en_linea: enLinea,
                    }));
                } catch (e) { /* ignore */ }
            }
        }
    }
}

const server = http.createServer(app);
const wss = new WebSocket.Server({
    server,
    path: '/ws/chat',
    maxPayload: 64 * 1024,  // 🔥 64 KB máximo por mensaje
});

// 🔥 SALAS: conversacion_id → Set<ws>
const salas = new Map();

// 🔥 BATCHING: acumular eventos y enviarlos cada 150ms
const pendientes = new Map(); // conversacion_id → { eventos: [], timer: Timeout }
const BATCH_INTERVALO_MS = 150;

function broadcast(conversacionId, payload) {
    const id = String(conversacionId);

    // 🔥 SI REDIS ESTÁ DISPONIBLE, PUBLICAR AHÍ
    if (redisDisponible && redisPub) {
        try {
            redisPub.publish('ws:eventos', JSON.stringify({
                conversacion_id: id,
                payload: payload,
            }));
        } catch (e) {
            console.log('>>> ❌ Error publicando en Redis:', e.message);
            // Fallback: entregar localmente
            entregarLocalmente(id, payload);
        }
        return;
    }

    // 🔥 SIN REDIS: comportamiento actual (1 réplica)
    if (!pendientes.has(id)) {
        pendientes.set(id, {
            eventos: [],
            timer: setTimeout(() => flushBatch(id), BATCH_INTERVALO_MS),
        });
    }

    pendientes.get(id).eventos.push(payload);
}

// 🔥 ENTREGAR A CLIENTES LOCALES (usado por Redis y por fallback)
function entregarLocalmente(conversacionId, payload) {
    const id = String(conversacionId);

    // Si hay batching activo, acumular
    if (!pendientes.has(id)) {
        pendientes.set(id, {
            eventos: [],
            timer: setTimeout(() => flushBatch(id), BATCH_INTERVALO_MS),
        });
    }
    pendientes.get(id).eventos.push(payload);
}

function flushBatch(conversacionId) {
    const batch = pendientes.get(conversacionId);
    if (!batch) return;
    pendientes.delete(conversacionId);

    const sala = salas.get(conversacionId);
    if (!sala || sala.size === 0) return;

    // Si hay 1 solo evento, enviarlo directo (más simple para el cliente)
    if (batch.eventos.length === 1) {
        const data = JSON.stringify(batch.eventos[0]);
        for (const ws of sala) {
            if (ws.readyState === WebSocket.OPEN) {
                try { ws.send(data); } catch (e) { /* ignore */ }
            }
        }
        return;
    }

    // Si hay varios, enviarlos como array
    const data = JSON.stringify({
        tipo: 'batch',
        eventos: batch.eventos,
    });
    for (const ws of sala) {
        if (ws.readyState === WebSocket.OPEN) {
            try { ws.send(data); } catch (e) { /* ignore */ }
        }
    }

    console.log(`>>> 📦 Batch enviado: ${batch.eventos.length} eventos a conv ${conversacionId}`);
}

// 🔥 Limpiar timers al cerrar el proceso
process.on('SIGTERM', () => {
    for (const [id, batch] of pendientes.entries()) {
        clearTimeout(batch.timer);
    }
    pendientes.clear();

    // 🔥 Cerrar conexiones Redis
    if (redisPub) redisPub.quit();
    if (redisSub) redisSub.quit();
});

global.broadcast = broadcast; // para usarlo desde otras funciones

// 🔥 MANEJO DE CONEXIONES
wss.on('connection', (ws, req) => {
    try {
        const params = new URLSearchParams(req.url.split('?')[1] || '');
        const conversacionId = params.get('conversacion_id');
        const usuarioId = params.get('usuario_id');

        if (!conversacionId || !usuarioId) {
            ws.close(1008, 'Faltan parámetros');
            return;
        }

        ws.conversacionId = String(conversacionId);
        ws.usuarioId = usuarioId;
        ws.isAlive = true;  // 🔥 HEARTBEAT

        // 🔥 MARCAR USUARIO COMO EN LÍNEA
        usuariosEnLinea.set(usuarioId, Date.now());
        console.log(`>>> 🟢 Usuario ${usuarioId} EN LÍNEA (total: ${usuariosEnLinea.size})`);
        broadcastPresencia(usuarioId, true);

        // 🔥 GUARDAR ÚLTIMA CONEXIÓN EN BD
        pool.query(
            'UPDATE usuarios SET ultima_conexion = NOW() WHERE uid = $1',
            [usuarioId]
        ).catch(e => console.log('>>> Error guardando ultima_conexion:', e.message));

        if (!salas.has(ws.conversacionId)) {
            salas.set(ws.conversacionId, new Set());
        }
        salas.get(ws.conversacionId).add(ws);

        console.log(`>>> 🔌 WS conectado: conv=${conversacionId}, user=${usuarioId} (total en sala: ${salas.get(ws.conversacionId).size})`);

        ws.send(JSON.stringify({ tipo: 'conectado' }));

        ws.on('message', (raw) => {
            try {
                const data = JSON.parse(raw.toString());

                // 🔥 ACTUALIZAR ÚLTIMA ACTIVIDAD
                usuariosEnLinea.set(ws.usuarioId, Date.now());

                // 🔥 HEARTBEAT: si responde pong, marcar viva
                if (data.tipo === 'pong') {
                    ws.isAlive = true;
                    return;
                }

                // Cliente pregunta ping → responder pong
                if (data.tipo === 'ping') {
                    ws.send(JSON.stringify({ tipo: 'pong' }));
                }
            } catch (e) { /* ignore */ }
        });

        ws.on('close', () => {
            const sala = salas.get(ws.conversacionId);
            if (sala) {
                sala.delete(ws);
                if (sala.size === 0) salas.delete(ws.conversacionId);
            }
            console.log(`>>> 🔌 WS desconectado: conv=${ws.conversacionId}, user=${ws.usuarioId}`);

            // 🔥 VERIFICAR SI EL USUARIO TIENE OTRAS CONEXIONES ABIERTAS
            const tieneOtras = Array.from(wss.clients).some(
                c => c.usuarioId === ws.usuarioId && c.readyState === WebSocket.OPEN
            );
            if (!tieneOtras) {
                usuariosEnLinea.delete(ws.usuarioId);
                console.log(`>>> 🔴 Usuario ${ws.usuarioId} OFFLINE (total: ${usuariosEnLinea.size})`);
                broadcastPresencia(ws.usuarioId, false);

                // 🔥 GUARDAR ÚLTIMA CONEXIÓN EN BD
                pool.query(
                    'UPDATE usuarios SET ultima_conexion = NOW() WHERE uid = $1',
                    [ws.usuarioId]
                ).catch(e => console.log('>>> Error guardando ultima_conexion:', e.message));
            }
        });

        ws.on('pong', () => {
            ws.isAlive = true;
            usuariosEnLinea.set(ws.usuarioId, Date.now()); // 🔥 NUEVO
        });

        ws.on('error', (e) => {
            console.log(`>>> ❌ WS error: ${e.message}`);
        });
    } catch (e) {
        console.log(`>>> ❌ WS connection error: ${e.message}`);
        try { ws.close(); } catch (_) {}
    }
});

// 🔥 HEARTBEAT: cada 30s verifica que todas las conexiones estén vivas
const HEARTBEAT_INTERVALO_MS = 15000; // 15s (proxy cierra a ~65s)
setInterval(() => {
    console.log(`>>> 💓 Heartbeat tick: ${wss.clients.size} conexiones activas`);
    wss.clients.forEach((ws) => {
        if (ws.isAlive === false) {
            console.log(`>>> 💀 WS zombi detectado, cerrando: conv=${ws.conversacionId}, user=${ws.usuarioId}`);
            return ws.terminate();
        }
        ws.isAlive = false;
        try {
            ws.ping();
            console.log(`>>> 📡 Ping enviado a conv=${ws.conversacionId}, user=${ws.usuarioId}`);
        } catch (e) {
            console.log(`>>> ❌ Error al ping: ${e.message}`);
        }
    });
}, HEARTBEAT_INTERVALO_MS);

app.use(cors());
app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true, limit: '2mb' }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const unique = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, unique + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

// ===== CONFIGURACIÓN PARA AUDIOS =====
const audioDir = path.join(__dirname, 'uploads/audios');
if (!fs.existsSync(audioDir)) {
    fs.mkdirSync(audioDir, { recursive: true });
}

const audioStorage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/audios/');
    },
    filename: (req, file, cb) => {
        const unique = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, unique + '.m4a');
    }
});

const uploadAudio = multer({ 
    storage: audioStorage,
    limits: { fileSize: 10 * 1024 * 1024 }
});

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});
// ============================================================
// 🔥 RATE LIMIT PARA RUTAS DE LECTURA (anti-scraping)
// ============================================================
// Map: `${ip}|${nombre}` → { count, reset }
const rateLimitLecturaMap = new Map();

function crearRateLimitLectura(nombre, maxRequests, ventanaMs = 60 * 1000) {
    return function rateLimitLectura(req, res, next) {
        const ip = (req.headers['x-forwarded-for'] || '').split(',')[0].trim()
            || req.socket.remoteAddress
            || 'desconocida';
        const key = `${ip}|${nombre}`;
        const ahora = Date.now();
        let entrada = rateLimitLecturaMap.get(key);

        if (!entrada || ahora > entrada.reset) {
            entrada = { count: 0, reset: ahora + ventanaMs };
            rateLimitLecturaMap.set(key, entrada);
        }

        entrada.count++;

        if (entrada.count > maxRequests) {
            const segRestantes = Math.ceil((entrada.reset - ahora) / 1000);
            console.log(`>>> 🚫 Rate limit lectura '${nombre}' excedido para IP ${ip} (${entrada.count} en la ventana, esperar ${segRestantes}s)`);
            return res.status(429).json({
                error: 'Demasiadas solicitudes. Esperá un momento.',
                codigo: 'RATE_LIMIT_LECTURA',
                segundos_restantes: segRestantes
            });
        }
        next();
    };
}

// Instancias con distintos límites
const rateLimitProductos = crearRateLimitLectura('productos', 60);
const rateLimitProducto = crearRateLimitLectura('producto', 60);
const rateLimitVendedor = crearRateLimitLectura('vendedor', 30);
const rateLimitBuscar = crearRateLimitLectura('buscar', 20);
const rateLimitCategoria = crearRateLimitLectura('categoria', 60);

// Limpiar el mapa cada 10 minutos
setInterval(() => {
    const ahora = Date.now();
    for (const [key, entrada] of rateLimitLecturaMap.entries()) {
        if (ahora > entrada.reset) rateLimitLecturaMap.delete(key);
    }
}, 10 * 60 * 1000);
// ============================================================
// 🔥 CRON PARA CADUCAR PRODUCTOS CADA 1 MINUTO
// ============================================================
const cron = require('node-cron');

cron.schedule('* * * * *', async () => {
    try {
        // 1. MARCAR PRODUCTOS CADUCADOS
        const query = `
            UPDATE productos_app 
            SET estado = 'caducado' 
            WHERE fecha_expiracion < NOW() AND estado = 'activo'
            RETURNING id, vendedor_id, nombre
        `;
        const result = await pool.query(query);
        
        if (result.rowCount > 0) {
            console.log(`>>> 📦 ${result.rowCount} productos marcados como caducados`);
            
            for (const row of result.rows) {
                // 2. VERIFICAR SI YA SE DIO EL AVISO PARA ESTE PRODUCTO
                const avisoExistente = await pool.query(
                    'SELECT id FROM alertas_caducidad WHERE producto_id = $1 AND usuario_id = $2',
                    [row.id, row.vendedor_id]
                );

                // 3. SI NO SE HA DADO AVISO, CREARLO
                if (avisoExistente.rows.length === 0) {
                    // CREAR ALERTA
                    await pool.query(
                        `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
                         VALUES ($1, $2, $3, $4, NOW())`,
                        [
                            row.vendedor_id,
                            row.id,
                            `⏰ Tu producto "${row.nombre}" ha caducado. Renueva viendo un anuncio.`,
                            'caducado'
                        ]
                    );
                    
                    // REGISTRAR QUE EL AVISO YA FUE DADO
                    await pool.query(
                        `INSERT INTO alertas_caducidad (producto_id, usuario_id, aviso_dado) 
                         VALUES ($1, $2, true)`,
                        [row.id, row.vendedor_id]
                    );
                    
                    console.log(`>>> 📩 Alerta de caducidad creada para producto ${row.id}`);
                } else {
                    console.log(`>>> ⏭️ Aviso ya dado para producto ${row.id}, omitiendo`);
                }
            }
        }
    } catch (error) {
        console.error('Error al caducar productos:', error);
    }
});
console.log('>>> ⏰ CRON de caducidad activado (cada 1 minuto)');

// ============================================================
// 🔥 CRON PARA BORRAR PRODUCTOS VENDIDOS (a los 3 días)
// ============================================================
cron.schedule('* * * * *', async () => {
    try {
        // 1. BUSCAR PRODUCTOS VENDIDOS HACE MÁS DE 3 DÍAS
        const productos = await pool.query(
            `SELECT id, nombre FROM productos_app 
             WHERE vendido = TRUE 
               AND fecha_vendido IS NOT NULL 
               AND fecha_vendido < NOW() - INTERVAL '3 days'`
        );

        if (productos.rowCount === 0) return;

        console.log(`>>> 🗑️ ${productos.rowCount} productos vendidos para borrar`);

        for (const prod of productos.rows) {
            // 2. DESVINCULAR DE CONVERSACIONES
            await pool.query(
                `UPDATE conversaciones_app SET producto_id = NULL WHERE producto_id = $1`,
                [prod.id]
            );

            // 3. DESVINCULAR DE FAVORITOS
            await pool.query(
                `DELETE FROM productos_favoritos WHERE producto_id::text = $1::text`,
                [prod.id]
            );

            // 4. BORRAR EL PRODUCTO
            await pool.query(
                `DELETE FROM productos_app WHERE id = $1`,
                [prod.id]
            );

            console.log(`>>> 🗑️ Borrado: ${prod.nombre} (ID: ${prod.id})`);
        }
    } catch (error) {
        console.error('Error al borrar productos vendidos:', error);
    }
});
console.log('>>> ⏰ CRON de borrado de productos vendidos activado (cada 1 minuto)');

// ============================================================
// 🔥 CRON DE RECORDATORIOS DE ENCUENTRO (cada 1 minuto)
// ============================================================
cron.schedule('* * * * *', async () => {
    try {
        // ============================================================
        // 1. RECORDATORIO 1 HORA ANTES
        // ============================================================
        const enUnaHora = await pool.query(
            `SELECT e.*, 
                    u1.fcm_token AS token1, u1.nombre AS nombre1,
                    u2.fcm_token AS token2, u2.nombre AS nombre2
             FROM encuentros_agendados e
             LEFT JOIN usuarios u1 ON e.usuario1_id = u1.uid
             LEFT JOIN usuarios u2 ON e.usuario2_id = u2.uid
             WHERE e.estado = 'agendado'
               AND e.recordatorio_1h_enviado = FALSE
               AND e.fecha_encuentro BETWEEN NOW() + INTERVAL '59 minutes'
                                          AND NOW() + INTERVAL '61 minutes'`
        );

        for (const enc of enUnaHora.rows) {
            const titulo = 'Encuentro en 1 hora';
            const cuerpo = `Tu encuentro es en 1 hora.\n${enc.lugar_nombre}\n\nLlegá 10 minutos antes.`;

            if (enc.token1) {
                try {
                    const { getMessaging } = require('firebase-admin/messaging');
                    await getMessaging().send({
                        token: enc.token1,
                        notification: { title: titulo, body: cuerpo },
                        data: { tipo: 'recordatorio_1h', encuentro_id: enc.id.toString() }
                    });
                    console.log(`>>> 📨 Push 1h enviada a ${enc.usuario1_id}`);
                } catch (e) { console.error('>>> ❌ Error push 1h:', e.message); }
            }
            if (enc.token2) {
                try {
                    const { getMessaging } = require('firebase-admin/messaging');
                    await getMessaging().send({
                        token: enc.token2,
                        notification: { title: titulo, body: cuerpo },
                        data: { tipo: 'recordatorio_1h', encuentro_id: enc.id.toString() }
                    });
                    console.log(`>>> 📨 Push 1h enviada a ${enc.usuario2_id}`);
                } catch (e) { console.error('>>> ❌ Error push 1h:', e.message); }
            }

            // 🔥 INSERTAR ALERTA EN LA APP
            try {
                await pool.query(
                    `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
                     VALUES ($1, 0, $2, 'recordatorio_encuentro', NOW()),
                            ($3, 0, $2, 'recordatorio_encuentro', NOW())`,
                    [enc.usuario1_id, `${titulo}\n${cuerpo}`, enc.usuario2_id]
                );
                console.log(`>>> 📥 Alerta 1h insertada para usuarios ${enc.usuario1_id} y ${enc.usuario2_id}`);
            } catch (e) { console.error('>>> ❌ Error INSERT alerta 1h:', e.message); }

            // 🔥 MARCAR COMO ENVIADO
            await pool.query(
                `UPDATE encuentros_agendados SET recordatorio_1h_enviado = TRUE WHERE id = $1`,
                [enc.id]
            );

            console.log(`>>> ⏰ Recordatorio 1h procesado para encuentro ${enc.id}`);
        }

        // ============================================================
        // 2. RECORDATORIO 10 MINUTOS ANTES
        // ============================================================
        const enDiezMin = await pool.query(
            `SELECT e.*, 
                    u1.fcm_token AS token1, u2.fcm_token AS token2
             FROM encuentros_agendados e
             LEFT JOIN usuarios u1 ON e.usuario1_id = u1.uid
             LEFT JOIN usuarios u2 ON e.usuario2_id = u2.uid
             WHERE e.estado = 'agendado'
               AND e.recordatorio_10m_enviado = FALSE
               AND e.fecha_encuentro BETWEEN NOW() + INTERVAL '9 minutes'
                                          AND NOW() + INTERVAL '11 minutes'`
        );

        for (const enc of enDiezMin.rows) {
            const titulo = 'Encuentro en 10 minutos';
            const cuerpo = `Estás a 10 minutos.\n${enc.lugar_nombre}\n\nAndá al lugar y hacé el reconocimiento facial.`;

            if (enc.token1) {
                try {
                    const { getMessaging } = require('firebase-admin/messaging');
                    await getMessaging().send({
                        token: enc.token1,
                        notification: { title: titulo, body: cuerpo },
                        data: { tipo: 'recordatorio_10m', encuentro_id: enc.id.toString() }
                    });
                    console.log(`>>> 📨 Push 10m enviada a ${enc.usuario1_id}`);
                } catch (e) { console.error('>>> ❌ Error push 10m:', e.message); }
            }
            if (enc.token2) {
                try {
                    const { getMessaging } = require('firebase-admin/messaging');
                    await getMessaging().send({
                        token: enc.token2,
                        notification: { title: titulo, body: cuerpo },
                        data: { tipo: 'recordatorio_10m', encuentro_id: enc.id.toString() }
                    });
                    console.log(`>>> 📨 Push 10m enviada a ${enc.usuario2_id}`);
                } catch (e) { console.error('>>> ❌ Error push 10m:', e.message); }
            }

            // 🔥 INSERTAR ALERTA EN LA APP
            try {
                await pool.query(
                    `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
                     VALUES ($1, 0, $2, 'recordatorio_encuentro', NOW()),
                            ($3, 0, $2, 'recordatorio_encuentro', NOW())`,
                    [enc.usuario1_id, `${titulo}\n${cuerpo}`, enc.usuario2_id]
                );
                console.log(`>>> 📥 Alerta 10m insertada para usuarios ${enc.usuario1_id} y ${enc.usuario2_id}`);
            } catch (e) { console.error('>>> ❌ Error INSERT alerta 10m:', e.message); }

            // 🔥 MARCAR COMO ENVIADO
            await pool.query(
                `UPDATE encuentros_agendados SET recordatorio_10m_enviado = TRUE WHERE id = $1`,
                [enc.id]
            );

            console.log(`>>> 🚨 Recordatorio 10m procesado para encuentro ${enc.id}`);
        }

        // ============================================================
        // 3. MARCAR 'TARDE' (5 min después de la hora)
        // ============================================================
        const marcadosTarde = await pool.query(
            `UPDATE encuentros_agendados 
             SET estado = 'tarde'
             WHERE estado = 'agendado'
               AND fecha_encuentro < NOW() - INTERVAL '5 minutes'
               AND fecha_encuentro > NOW() - INTERVAL '6 minutes'
             RETURNING id`
        );
        if (marcadosTarde.rowCount > 0) {
            console.log(`>>> ⏳ ${marcadosTarde.rowCount} encuentros marcados como 'tarde'`);
        }

        // ============================================================
        // 4. MARCAR 'NO_PRESENTADO' (15 min después de la hora)
        // ============================================================
        const marcadosNoPresentado = await pool.query(
            `UPDATE encuentros_agendados 
             SET estado = 'no_presentado'
             WHERE estado IN ('agendado', 'tarde')
               AND fecha_encuentro < NOW() - INTERVAL '15 minutes'
               AND fecha_encuentro > NOW() - INTERVAL '16 minutes'
             RETURNING id`
        );
        if (marcadosNoPresentado.rowCount > 0) {
            console.log(`>>> 🚫 ${marcadosNoPresentado.rowCount} encuentros marcados como 'no_presentado'`);
        }

    } catch (error) {
        console.error('Error en cron de recordatorios:', error);
    }
});
console.log('>>> ⏰ CRON de recordatorios de encuentro activado (cada 1 minuto)');

// ===== FUNCIÓN DE MODERACIÓN CON DEEPSEEK =====
async function moderarProducto(nombre, descripcion, categoria, imagenUrl) {
    try {
        const prompt = `
Eres un moderador de un marketplace. Analiza este producto y determina si viola las reglas de publicación.

REGLAS PROHIBIDAS:
- Celulares (iPhone, Samsung Galaxy, Xiaomi, etc.)
- Consolas de videojuegos modernas (PlayStation, Xbox, Nintendo Switch)
- Armas de cualquier tipo (cuchillos, pistolas, rifles, etc.)
- Animales vivos (perros, gatos, aves, etc.)
- Artículos eróticos o sexuales (juguetes sexuales, lencería, etc.)
- Equipo médico (termómetros, tensiómetros, kits de prueba, etc.)

DATOS DEL PRODUCTO:
Nombre: ${nombre}
Descripción: ${descripcion}
Categoría: ${categoria}

RESPONDE ÚNICAMENTE CON UN JSON VÁLIDO. NO agregues texto adicional. NO uses comillas simples. Usa SOLO el formato JSON.

{
  "aprobado": true/false,
  "motivo": "explicación breve en español si es rechazado"
}
`;

        // Construir contenido para el modelo de visión
        const contenido = [
            { type: 'text', text: prompt }
        ];

        // Si hay imagen, agregarla
        if (imagenUrl && imagenUrl.startsWith('http')) {
            contenido.push({
                type: 'image_url',
                image_url: { url: imagenUrl }
            });
        }

        const response = await axios.post(
            'https://api.deepseek.com/v1/chat/completions',
            {
                model: 'deepseek-v4-flash-vision-exp',
                messages: [
                    { role: 'user', content: contenido }
                ],
                temperature: 0.1,
                max_tokens: 200,
            },
            {
                headers: {
                   'Authorization': `Bearer sk-caf5d299870944738158dac0973b7463`,
                    'Content-Type': 'application/json'
                }
            }
        );

        const texto = response.data.choices[0].message.content;
        console.log('>>> RESPUESTA DE DEEPSEEK:', texto);
        const resultado = JSON.parse(texto);
        return resultado;
    } catch (error) {
        console.error('Error en moderación:', error.response?.data || error.message);
        return { aprobado: true, motivo: '' };
    }
}
// ===== MODERACIÓN CON DEEPSEEK VISION =====
async function moderarProductoConGemini(nombre, descripcion, categoria, imagenPath) {
    try {
        console.log('>>> 🚨🚨🚨 DEEPSEEK LLAMADO DESDE moderarProductoConGemini');
        console.log('>>> 🚨 Producto:', nombre);
        const fullPath = path.join(__dirname, imagenPath.replace(/^\//, ''));
        console.log('>>> Leyendo imagen desde:', fullPath);
        
        const imageBuffer = fs.readFileSync(fullPath);
        
        // 🔥 CONVERTIR AVIF A JPEG
        let processedBuffer = imageBuffer;
        const ext = path.extname(fullPath).toLowerCase();
        if (ext === '.avif') {
            console.log('>>> 🔥 AVIF detectado (moderación), convirtiendo a JPEG...');
            processedBuffer = await sharp(imageBuffer)
                .jpeg({ quality: 75 })
                .toBuffer();
        }
        const resizedBuffer = await sharp(processedBuffer)
            .resize(800, 800, { fit: 'inside', withoutEnlargement: true })
            .jpeg({ quality: 75 })
            .toBuffer();
        const imageBase64 = resizedBuffer.toString('base64');

        const prompt = `Eres un moderador de un marketplace. Analiza esta imagen de producto.

REGLAS PROHIBIDAS:
- Celulares, consolas de videojuegos, armas, animales vivos, artículos eróticos, equipo médico

DATOS:
Nombre: ${nombre}
Descripción: ${descripcion}
Categoría: ${categoria}

RESPONDE ÚNICAMENTE CON ESTE JSON:
{"aprobado": true/false, "motivo": "explicación breve si es rechazado"}

NO agregues texto adicional. SOLO el JSON.`;

        const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;  // ✅ BIEN
        const url = 'https://api.deepseek.com/v1/chat/completions';

        const response = await axios.post(url, {
            model: 'deepseek-v4-flash-vision-exp',
            messages: [
                {
                    role: 'user',
                    content: [
                        { type: 'text', text: prompt },
                        {
                            type: 'image_url',
                            image_url: {
                                url: `data:image/jpeg;base64,${imageBase64}`
                            }
                        }
                    ]
                }
            ],
            temperature: 0.1,
            max_tokens: 200,
        }, {
            headers: {
                'Authorization': `Bearer ${DEEPSEEK_API_KEY}`,
                'Content-Type': 'application/json'
            },
            timeout: 30000
        });

        const text = response.data.choices[0].message.content;
        console.log('>>> Respuesta de DeepSeek (moderación):', text);

        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            try {
                const resultado = JSON.parse(jsonMatch[0]);
                console.log('>>> ✅ JSON parseado (moderación):', resultado);
                return {
                    aprobado: resultado.aprobado === true,
                    motivo: resultado.motivo || 'Producto no permitido'
                };
            } catch (e) {
                console.log('>>> ❌ Error al parsear JSON:', e.message);
                console.log('>>> Texto recibido:', text);
            }
        }

        console.log('>>> ⚠️ No se encontró JSON, aprobando por defecto');
        return { aprobado: true, motivo: '' };

    } catch (error) {
        console.error('Error en moderarProductoConGemini:', error.message);
        if (error.response) {
            console.error('>>> Detalles:', error.response.status, error.response.data);
        }
        return { aprobado: true, motivo: '' };
    }
}
async function _verificarYPedirCalificacion(conversacionId) {
    try {
        console.log('>>> 🔥 ====== _verificarYPedirCalificacion INICIO ======');
        console.log('>>> 🔥 conversacionId:', conversacionId);
        
        const convResult = await pool.query(
            `SELECT c.*, 
             u1.nombre AS nombre1, u2.nombre AS nombre2,
             u1.uid AS uid1, u2.uid AS uid2,
             p.vendedor_id
             FROM conversaciones_app c
             LEFT JOIN usuarios u1 ON c.usuario1_id = u1.uid
             LEFT JOIN usuarios u2 ON c.usuario2_id = u2.uid
             LEFT JOIN productos_app p ON c.producto_id = p.id
             WHERE c.id = $1`,
            [conversacionId]
        );

        if (convResult.rows.length === 0) {
            console.log('>>> 🔥 CONVERSACIÓN NO ENCONTRADA');
            return;
        }
        
        const conv = convResult.rows[0];
        console.log('>>> 🔥 conv.uid1:', conv.uid1);
        console.log('>>> 🔥 conv.uid2:', conv.uid2);
        console.log('>>> 🔥 conv.vendedor_id:', conv.vendedor_id);
        console.log('>>> 🔥 conv.producto_id:', conv.producto_id);

        const mensajesResult = await pool.query(
            `SELECT usuario_id, COUNT(*) as total
             FROM mensajes_app
             WHERE conversacion_id = $1
             GROUP BY usuario_id`,
            [conversacionId]
        );

        console.log('>>> 🔥 mensajesResult:', mensajesResult.rows);

        const usuario1Mensajes = mensajesResult.rows.find(r => r.usuario_id === conv.uid1)?.total || 0;
        const usuario2Mensajes = mensajesResult.rows.find(r => r.usuario_id === conv.uid2)?.total || 0;

        console.log('>>> 🔥 usuario1Mensajes:', usuario1Mensajes);
        console.log('>>> 🔥 usuario2Mensajes:', usuario2Mensajes);

        if (usuario1Mensajes >= 5 && usuario2Mensajes >= 5) {
            console.log('>>> 🔥 AMBOS TIENEN 5+ MENSAJES ✅');

            // 🔥 VERIFICAR SI YA CALIFICÓ (para no insertar de nuevo)
            const compradorIdCheck = conv.uid1 === conv.vendedor_id ? conv.uid2 : conv.uid1;
             const yaCalifico = await pool.query(
                `SELECT id FROM calificaciones 
                 WHERE producto_id = $1 
                   AND calificador_id = $2`,
                [conv.producto_id, compradorIdCheck]
            );

            if (yaCalifico.rows.length > 0) {
                console.log('>>> 🔥 YA CALIFICÓ - NO INSERTAR SOLICITUD');
                return;
            }
            
            const solicitudResult = await pool.query(
                `SELECT * FROM mensajes_app 
                 WHERE conversacion_id = $1 
                 AND texto LIKE '%EL_COMPRADOR_YA_PUEDE_CALIFICARTE%'`,
                [conversacionId]
            );

            console.log('>>> 🔥 solicitudResult.rows.length:', solicitudResult.rows.length);

            if (solicitudResult.rows.length === 0) {
                console.log('>>> 🔥 NO HAY SOLICITUD PREVIA - INSERTANDO...');
                
                const compradorId = conv.uid1 === conv.vendedor_id ? conv.uid2 : conv.uid1;
                console.log('>>> 🔥 compradorId (quien recibe el mensaje):', compradorId);
                
                const mensajeTexto = `||EL_COMPRADOR_YA_PUEDE_CALIFICARTE||`;
                
                // 🔥 INSERTAR SIN DISPARAR ANÁLISIS (no llama a DeepSeek)
                const insertResult = await pool.query(
                    `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
                     VALUES ($1, $2, $3, $4, NOW()) RETURNING *`,
                    [conversacionId, 'SYSTEM', mensajeTexto, '']
                );
                
                console.log('>>> 🔥 MENSAJE INSERTADO:', insertResult.rows[0]);
                console.log('>>> 🔥 usuario_id del mensaje:', insertResult.rows[0].usuario_id);
                console.log('>>> ✅ Solicitud de calificación enviada SOLO al comprador:', compradorId);
            } else {
                console.log('>>> 🔥 YA EXISTE SOLICITUD PREVIA - OMITIENDO');
            }
        } else {
            console.log('>>> 🔥 NO AMBOS TIENEN 5+ MENSAJES ❌');
        }
    } catch (error) {
        console.error('>>> 🔥 ERROR EN _verificarYPedirCalificacion:', error);
    }
}
// RUTAS GET
app.get('/', (req, res) => {
    res.send('API funcionando correctamente');
});



app.get('/api/productos/buscar', rateLimitBuscar, async (req, res) => {
    console.log('>>> BUSCANDO:', req.query.q);
    try {
        const { q } = req.query;
        if (!q || q.length < 2) {
            return res.json([]);
        }
        const result = await pool.query(
            `SELECT p.*, u.nombre AS vendedor_nombre, u.foto_perfil AS vendedor_foto
             FROM productos_app p
             LEFT JOIN usuarios u ON p.vendedor_id = u.uid
             WHERE (p.nombre ILIKE $1 OR p.descripcion ILIKE $1) 
             AND p.estado_moderacion = 'aprobado'
             AND p.estado = 'activo'
             AND COALESCE(p.vendido, FALSE) = FALSE`,
            [`%${q}%`]
        );
        console.log('>>> ENCONTRADOS:', result.rows.length);
        res.json(result.rows);
    } catch (error) {
        console.error('ERROR:', error);
        res.status(500).json({ error: error.message });
    } 
});

// ============================================================
// 🔥 IMPULSAR PRODUCTOS (DEBE IR ANTES DE /api/productos/:id)
// ============================================================

// GET /api/productos/impulsados
app.get('/api/productos/impulsados', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        p.*,
        i.fecha_impulso
      FROM productos_impulsados i
      INNER JOIN productos_app p ON p.id = i.producto_id
      WHERE i.activo = TRUE
        AND p.estado_moderacion = 'aprobado'
        AND p.estado = 'activo'
        AND COALESCE(p.vendido, FALSE) = FALSE
      ORDER BY i.fecha_impulso DESC
      LIMIT 20
    `);

    console.log('>>> IMPULSADOS DEVUELTOS:', result.rows.length);

    res.json(result.rows);

  } catch (error) {
    console.error('>>> ERROR AL OBTENER IMPULSADOS:', error);
    res.status(500).json({ error: 'Error al obtener impulsados' });
  }
});

// POST /api/productos/:id/impulsar
app.post('/api/productos/:id/impulsar', verificarTokenFirebase, async (req, res) => {
  try {
    const { id } = req.params;
    const { usuario_id } = req.body;

    console.log('>>> IMPULSAR: producto', id, 'usuario', usuario_id);
    console.log('>>> 🔐 Usuario autenticado (token):', req.usuarioAutenticado);

    if (!usuario_id) {
      return res.status(400).json({ error: 'Falta usuario_id' });
    }

    // 🔥 Verificar que el usuario_id del body coincida con el del token
    if (usuario_id !== req.usuarioAutenticado) {
      console.log('>>> ❌ UID no coincide en impulsar producto');
      return res.status(403).json({
        error: 'No autorizado para impulsar este producto',
        codigo: 'UID_NO_COINCIDE'
      });
    }

    const producto = await pool.query(
      'SELECT * FROM productos_app WHERE id = $1 AND vendedor_id = $2',
      [id, usuario_id]
    );

    if (producto.rows.length === 0) {
      return res.status(403).json({ error: 'No tenés permiso sobre este producto' });
    }

    await pool.query(
      'UPDATE productos_impulsados SET activo = FALSE WHERE producto_id = $1',
      [id]
    );

    const result = await pool.query(
      `INSERT INTO productos_impulsados (producto_id, usuario_id)
       VALUES ($1, $2) RETURNING *`,
      [id, usuario_id]
    );

    console.log('>>> IMPULSO CREADO:', result.rows[0]);

    res.json({ success: true, impulso: result.rows[0] });

  } catch (error) {
    console.error('>>> ERROR AL IMPULSAR:', error);
    res.status(500).json({ error: 'Error al impulsar producto' });
  }
});

app.get('/api/productos/:id', rateLimitProducto, async (req, res) => {
    try {
        const { id } = req.params;
        console.log('>>> ID RECIBIDO EN GET /api/productos/:id:', id);
        console.log('>>> TIPO DEL ID:', typeof id); // ← AGREGAR ESTO
        
        const result = await pool.query(
            `SELECT p.*, u.foto_perfil AS vendedor_foto
             FROM productos_app p
             LEFT JOIN usuarios u ON p.vendedor_id = u.uid
             WHERE p.id = $1`,
            [id]
        );
        
        console.log('>>> RESULTADOS ENCONTRADOS:', result.rows.length);
        console.log('>>> RESULTADOS:', result.rows); // ← AGREGAR ESTO
        
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Producto no encontrado' });
        }
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error al obtener producto:', error);
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/productos/categoria/:categoria', rateLimitCategoria, async (req, res) => {
    try {
        const { categoria } = req.params;
        const result = await pool.query(
            `SELECT p.*, u.nombre AS vendedor_nombre, u.foto_perfil AS vendedor_foto 
             FROM productos_app p
             LEFT JOIN usuarios u ON p.vendedor_id = u.uid
             WHERE p.categoria = $1 
               AND p.estado_moderacion = 'aprobado' 
               AND p.estado = 'activo'
               AND COALESCE(p.vendido, FALSE) = FALSE`,
            [categoria]
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/productos', rateLimitProductos, async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT * FROM productos_app 
             WHERE estado_moderacion = $1 
               AND estado = $2
               AND COALESCE(vendido, FALSE) = FALSE
             ORDER BY id DESC`,
            ['aprobado', 'activo']
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


app.get('/api/productos/vendedor/:vendedor_id', rateLimitVendedor, async (req, res) => {
    try {
        const { vendedor_id } = req.params;
        const result = await pool.query(
            `SELECT p.*, u.nombre AS vendedor_nombre, u.foto_perfil AS vendedor_foto
             FROM productos_app p
             LEFT JOIN usuarios u ON p.vendedor_id = u.uid
             WHERE p.vendedor_id = $1 
               AND p.estado_moderacion = 'aprobado'
               AND COALESCE(p.vendido, FALSE) = FALSE`,
            [vendedor_id]
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/productos', verificarTokenFirebase, upload.fields([
  { name: 'imagen_destacada', maxCount: 1 },
  { name: 'imagen_normal', maxCount: 1 },
  { name: 'imagenes_reales[]', maxCount: 5 }
]), async (req, res) => {
    try {
        const { nombre, descripcion, precio, categoria, subcategoria, vendedor_id, direccion } = req.body;
        
        console.log('>>> 📦 Crear producto. Usuario autenticado:', req.usuarioAutenticado);
        console.log('>>> 📦 Vendedor del body:', vendedor_id);

        // 🔥 Verificar que el vendedor_id del body coincida con el del token
        if (vendedor_id !== req.usuarioAutenticado) {
            if (req.files) {
                const todosLosArchivos = [];
                if (req.files['imagen_destacada']) todosLosArchivos.push(...req.files['imagen_destacada']);
                if (req.files['imagen_normal']) todosLosArchivos.push(...req.files['imagen_normal']);
                if (req.files['imagenes_reales[]']) todosLosArchivos.push(...req.files['imagenes_reales[]']);
                for (const f of todosLosArchivos) {
                    try { fs.unlinkSync(f.path); } catch (_) {}
                }
            }
            console.log('>>> ❌ UID no coincide, rechazando publicación');
            return res.status(403).json({
                error: 'No autorizado para publicar a nombre de este usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        console.log('>>> ✅ UID coincide, procediendo a publicar');
        
        // Obtener URLs de las imágenes
        const imagen_destacada_url = req.files['imagen_destacada'] ? `/uploads/${req.files['imagen_destacada'][0].filename}` : '';
        // ===== IMAGEN PRINCIPAL: PRIMERO LA DESTACADA, SINO LA PRIMERA REAL =====
let imagen_principal_url = '';
// 🔥 PRIMERO INTENTAR USA LA PRIMERA IMAGEN REAL COMO PRINCIPAL
if (req.files['imagenes_reales[]'] && req.files['imagenes_reales[]'].length > 0) {
    imagen_principal_url = `/uploads/${req.files['imagenes_reales[]'][0].filename}`;
} else if (req.files['imagen_destacada']) {
    // Solo si no hay reales, usar destacada
    const file = req.files['imagen_destacada'][0];
    const outputPath = `uploads/destacadas/${file.filename}`;
    await sharp(file.path)
        .resize(400, 400, { fit: 'inside' })
        .jpeg({ quality: 70 })
        .toFile(outputPath);
    fs.unlinkSync(file.path);
    imagen_destacada_url = `/uploads/destacadas/${file.filename}`;
    imagen_principal_url = imagen_destacada_url;
}
// ============================================================
// 🔥 GENERAR MINIATURA (300x300) PARA LA IMAGEN PRINCIPAL
// ============================================================
let imagen_miniatura_url = '';
if (imagen_principal_url) {
    try {
        const ext = path.extname(imagen_principal_url);
        const nombreBase = path.basename(imagen_principal_url, ext);
        const miniaturaPath = `uploads/miniaturas/${nombreBase}_thumb${ext}`;
        
        // Crear carpeta de miniaturas si no existe
        if (!fs.existsSync('uploads/miniaturas')) {
            fs.mkdirSync('uploads/miniaturas', { recursive: true });
        }
        
        // 🔥 REDIMENSIONAR A 300x300 (RECORTAR PARA CUADRADO)
        await sharp(path.join(__dirname, imagen_principal_url.replace(/^\//, '')))
            .resize(300, 300, { fit: 'cover' })
            .jpeg({ quality: 70 })
            .toFile(path.join(__dirname, miniaturaPath));
        
        imagen_miniatura_url = `/${miniaturaPath}`;
        console.log('>>> ✅ Miniatura generada:', imagen_miniatura_url);
    } catch (error) {
        console.error('Error al generar miniatura:', error);
        imagen_miniatura_url = imagen_principal_url; // Fallback
    }
}

const imagen_normal_url = req.files['imagen_normal'] ? `/uploads/${req.files['imagen_normal'][0].filename}` : '';
        
        // URLs de imágenes reales (hasta 5)
       let imagenes_reales_urls = [];
if (req.files['imagenes_reales[]']) {
    imagenes_reales_urls = req.files['imagenes_reales[]'].map(file => `/uploads/${file.filename}`);
}
// ===== ELIMINAR LA IMAGEN PRINCIPAL DE LAS REALES (SI EXISTE) =====
if (imagen_principal_url) {
    imagenes_reales_urls = imagenes_reales_urls.filter(url => url !== imagen_principal_url);
}
const imagenes_reales_json = JSON.stringify(imagenes_reales_urls);

        let vendedor_nombre = '';
        let provincia = '';
        let canton = '';
        if (vendedor_id) {
            const userResult = await pool.query('SELECT nombre FROM usuarios WHERE uid = $1', [vendedor_id]);
            if (userResult.rows.length > 0) {
                vendedor_nombre = userResult.rows[0].nombre;
            }
        }

        // Obtener provincia Y cantón desde las coordenadas
        if (direccion && direccion.includes(',')) {
            try {
                const latLng = direccion.split(',');
                const lat = latLng[0].replace('Lat: ', '').trim();
                const lng = latLng[1].replace('Lng: ', '').trim();
                const geoResponse = await axios.get(
                    `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json&addressdetails=1&zoom=10`,
                    { headers: { 'User-Agent': 'MiMarketplaceCR/1.0 (contacto@mimarketplace.com)' } }
                );
                const address = geoResponse.data.address;
                provincia = address.state || address.region || address.province || '';
                canton = address.county || address.city || address.town || address.municipality || '';
                console.log('>>> 📍 Provincia:', provincia, '| Cantón:', canton);
            } catch (e) {
                console.log('Error al obtener provincia:', e.message);
            }
        }

        // ===== GUARDAR CON ESTADO PENDIENTE =====
        const result = await pool.query(
            `INSERT INTO productos_app 
            (nombre, descripcion, precio, categoria, subcategoria, vendedor_id, direccion, imagen_url, vendedor_nombre, provincia, canton, imagen_destacada, imagenes_reales, estado_moderacion, estado, fecha_expiracion, imagen_miniatura) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, 'pendiente', 'activo', NOW() + INTERVAL '30 days', $14) 
            RETURNING *`,
            [nombre, descripcion, precio, categoria, subcategoria, vendedor_id, direccion, imagen_principal_url || '', vendedor_nombre, provincia, canton, imagen_destacada_url, imagenes_reales_json, imagen_miniatura_url || '']
        );

        const producto = result.rows[0];

        // ===== CREAR ALERTA DE PENDIENTE =====
        try {
            await pool.query(
                `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
                 VALUES ($1, $2, $3, $4, NOW())`,
                [
                    producto.vendedor_id,
                    producto.id,
                    `📝 Tu producto "${producto.nombre}" está en proceso de revisión. Recibirás una notificación cuando sea aprobado.`,
                    'pendiente'
                ]
            );
            console.log('>>> Alerta pendiente creada para el producto:', producto.id);
        } catch (err) {
            console.error('Error al crear alerta pendiente:', err);
        }

        // ============================================================
        // 🔥 MODERACIÓN CON GEMINI (ANÁLISIS DE PRIMERA IMAGEN REAL)
        // ============================================================
        // ============================================================
                // ============================================================
        // 🔥 MODERACIÓN CON GEMINI (EN SEGUNDO PLANO)
        // ============================================================
        (async () => {
            try {
                let primeraImagenLocal = null;
                
                // 🔥 PRIORIZAR IMAGEN DESTACADA
                if (imagen_destacada_url) {
                    primeraImagenLocal = imagen_destacada_url;
                } else if (imagenes_reales_urls && imagenes_reales_urls.length > 0) {
                    primeraImagenLocal = imagenes_reales_urls[0];
                } else if (imagen_principal_url) {
                    primeraImagenLocal = imagen_principal_url;
                }

                if (primeraImagenLocal) {
                    console.log('>>> Moderando imagen en segundo plano:', primeraImagenLocal);

                    const resultadoModeracion = await moderarProductoConGemini(
                        producto.nombre,
                        producto.descripcion,
                        producto.categoria,
                        primeraImagenLocal
                    );

                    if (resultadoModeracion.aprobado) {
                        await pool.query(
                            `UPDATE productos_app SET estado_moderacion = 'aprobado' WHERE id = $1`,
                            [producto.id]
                        );
                        console.log('>>> Producto APROBADO por IA en segundo plano:', producto.id);
                        
                        await pool.query(
                            `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
                             VALUES ($1, $2, $3, $4, NOW())`,
                            [
                                producto.vendedor_id,
                                producto.id,
                                `✅ Tu producto "${producto.nombre}" ha sido APROBADO y ya está visible.`,
                                'exito'
                            ]
                        );
                    } else {
                        await pool.query(
                            `UPDATE productos_app SET estado_moderacion = 'rechazado', motivo_rechazo = $1 WHERE id = $2`,
                            [resultadoModeracion.motivo, producto.id]
                        );
                        console.log('>>> Producto RECHAZADO por IA en segundo plano:', producto.id, 'Motivo:', resultadoModeracion.motivo);

                        await pool.query(
                            `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
                             VALUES ($1, $2, $3, $4, NOW())`,
                            [
                                producto.vendedor_id,
                                producto.id,
                                `❌ Tu producto "${producto.nombre}" fue rechazado: ${resultadoModeracion.motivo}`,
                                'error'
                            ]
                        );
                    }
                } else {
                    await pool.query(
                        `UPDATE productos_app SET estado_moderacion = 'aprobado' WHERE id = $1`,
                        [producto.id]
                    );
                    console.log('>>> Producto APROBADO (sin imagen) en segundo plano:', producto.id);
                    
                    await pool.query(
                        `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
                         VALUES ($1, $2, $3, $4, NOW())`,
                        [
                            producto.vendedor_id,
                            producto.id,
                            `✅ Tu producto "${producto.nombre}" ha sido APROBADO y ya está visible.`,
                            'exito'
                        ]
                    );
                }
            } catch (error) {
                console.error('Error en moderación en segundo plano:', error);
                await pool.query(
                    `UPDATE productos_app SET estado_moderacion = 'aprobado' WHERE id = $1`,
                    [producto.id]
                );
                console.log('>>> Producto APROBADO por defecto (error en IA):', producto.id);
            }
        })();

        res.status(201).json({
            ...producto,
            estado_moderacion: 'pendiente',
            mensaje: 'Producto enviado para moderación. Recibirás una notificación cuando sea aprobado.'
        });
    } catch (error) {
        console.error('Error al guardar producto:', error);
        res.status(500).json({ error: error.message });
    }
});
// 🔥 FUNCIÓN PARA DETECTAR NÚMEROS DE TELÉFONO DE COSTA RICA
function contieneNumeroTelefono(texto) {
    if (!texto) return false;

    // 🔥 Patrones de números de Costa Rica
    const patrones = [
        /\b[678]\d{3}[- ]?\d{4}\b/,        // 8888-8888, 8888 8888, 88888888
        /\b[678]\d{7}\b/,                    // 88888888
        /\+506[- ]?\d{4}[- ]?\d{4}/,         // +506 8888-8888
        /00506[- ]?\d{4}[- ]?\d{4}/,         // 00506 8888-8888
        /\b506[- ]?\d{4}[- ]?\d{4}\b/,       // 506 8888-8888
        /\b[678]\d{3}[- ]?\d{4}\b/,          // 8888-8888
    ];

    return patrones.some(p => p.test(texto));
}

app.post('/api/mensajes', verificarTokenFirebase, upload.single('imagen'), async (req, res) => {
    try {
        console.log('>>> Archivo recibido:', req.file);
        const { conversacion_id, usuario_id, texto } = req.body;
        const imagen_url = req.file ? `/uploads/${req.file.filename}` : '';

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            if (req.file) { try { fs.unlinkSync(req.file.path); } catch (_) {} }
            return res.status(403).json({
                error: 'No autorizado para enviar mensajes con este usuario_id',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 VERIFICAR SI EL CHAT ESTÁ BLOQUEADO
        const bloqueadoResult = await pool.query(
            `SELECT chat_bloqueado FROM conversaciones_app WHERE id = $1`,
            [conversacion_id]
        );
        if (bloqueadoResult.rows[0]?.chat_bloqueado === true) {
            return res.status(403).json({
                error: 'El chat está bloqueado. Confirma el encuentro en persona.',
                codigo: 'CHAT_BLOQUEADO'
            });
        }

        // 🔥 VERIFICAR SI EL ESCUDO ESTÁ ACTIVO
        const escudoResult = await pool.query(
            `SELECT activo FROM escudos_conversacion 
             WHERE conversacion_id = $1 AND usuario_id = $2`,
            [conversacion_id, usuario_id]
        );
        const escudoActivo = escudoResult.rows[0]?.activo === true;

        // 🔥 SI EL ESCUDO ESTÁ ACTIVO Y EL TEXTO TIENE UN NÚMERO, BLOQUEAR
        if (escudoActivo && contieneNumeroTelefono(texto)) {
            console.log('>>> 🛡️ MENSAJE BLOQUEADO: contiene número de teléfono');
            return res.status(403).json({
                error: 'El Escudo de Seguridad bloqueó este mensaje',
                motivo: 'No se permiten números de teléfono',
                codigo: 'NUMERO_TELEFONO'
            });
        }

        // 1. GUARDAR EL MENSAJE
        const result = await pool.query(
            `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
             VALUES ($1, $2, $3, $4, NOW()) RETURNING *`,
            [conversacion_id, usuario_id, texto, imagen_url]
        );

        // 🔥 EMITIR POR WEBSOCKET A TODOS LOS DE LA SALA
        global.broadcast(conversacion_id, {
            tipo: 'nuevo_mensaje',
            mensaje: result.rows[0],
        });

        // 🔥 NO borrar la fila: mantener fecha_ocultado para seguir filtrando mensajes viejos
        // El chat reaparece en la lista por el cambio en GET /api/conversaciones
        console.log(`>>> 🔄 Mensaje guardado, conversación ${conversacion_id} mantiene fecha_ocultado`);


        const escudoVerif = await pool.query(
            `SELECT activo FROM escudos_conversacion 
             WHERE conversacion_id = $1 AND usuario_id = $2`,
            [conversacion_id, usuario_id]
        );
        const escudoDeEsteUsuario = escudoVerif.rows[0]?.activo === true;

        if (escudoDeEsteUsuario) {
            console.log('>>> 🛡️ Escudo activo → analizando con DeepSeek');
            analizarConversacionEnSegundoPlano(conversacion_id, usuario_id);
        } else {
            console.log('>>> ⏭️ Escudo apagado → sin análisis');
        }

        // 3. VERIFICAR SI HAY QUE PEDIR CALIFICACIÓN (SIN LLAMAR A DEEPSEEK)
        await _verificarYPedirCalificacion(conversacion_id);

        // ============================================================
        // 🔥 ENVIAR NOTIFICACIÓN PUSH (DESPUÉS DE GUARDAR MENSAJE)
        // ============================================================
        try {
            // Obtener el receptor de la conversación
            const convResult = await pool.query(
                `SELECT usuario1_id, usuario2_id, producto_nombre 
                 FROM conversaciones_app 
                 WHERE id = $1`,
                [conversacion_id]
            );

            if (convResult.rows.length > 0) {
                const conv = convResult.rows[0];
                const receptor_id = conv.usuario1_id === usuario_id 
                    ? conv.usuario2_id 
                    : conv.usuario1_id;

                // Obtener FCM token del receptor
                const tokenResult = await pool.query(
                    `SELECT fcm_token, nombre FROM usuarios WHERE uid = $1`,
                    [receptor_id]
                );

                const fcmToken = tokenResult.rows[0]?.fcm_token;
                const nombreReceptor = tokenResult.rows[0]?.nombre || 'Usuario';

                // Obtener nombre del emisor
                const emisorResult = await pool.query(
                    `SELECT nombre FROM usuarios WHERE uid = $1`,
                    [usuario_id]
                );
                const nombreEmisor = emisorResult.rows[0]?.nombre || 'Usuario';

                // Solo enviar si hay token y no es el mismo usuario
                if (fcmToken && receptor_id !== usuario_id) {
                    const mensajeFCM = {
                        token: fcmToken,
                        notification: {
                            title: `💬 ${nombreEmisor}`,
                            body: texto && texto.length > 0 
                                ? (texto.length > 50 ? texto.substring(0, 50) + '...' : texto)
                                : '📷 Te envió una imagen',
                        },
                        data: {
                            conversacionId: conversacion_id.toString(),
                            otroUsuario: nombreEmisor,
                            otroUsuarioId: usuario_id,
                            nombreProducto: conv.producto_nombre || 'Producto',
                            tipo: imagen_url ? 'imagen' : 'texto',
                        },
                    };

                    // Enviar con Admin SDK
                    try {
                        const { getMessaging } = require('firebase-admin/messaging');
                        await getMessaging().send(mensajeFCM);
                        console.log('>>> 📨 Notificación push enviada a:', receptor_id);
                    } catch (pushError) {
                        console.error('>>> ❌ Error al enviar push:', pushError.message);
                    }
                }
            }
        } catch (pushError) {
            // No interrumpir el flujo si falla la notificación
            console.error('>>> ❌ Error enviando notificación push:', pushError);
        }

        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('Error al guardar mensaje:', error);
        res.status(500).json({ error: error.message });
    }
});


// ===== RUTA PARA SUBIR AUDIO EN EL CHAT =====
app.post('/api/mensajes/audio', verificarTokenFirebase, uploadAudio.single('audio'), async (req, res) => {
    try {
        const { conversacion_id, usuario_id, texto } = req.body;
        const audio_url = req.file ? `/uploads/audios/${req.file.filename}` : '';

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            if (req.file) { try { fs.unlinkSync(req.file.path); } catch (_) {} }
            return res.status(403).json({
                error: 'No autorizado para enviar audios con este usuario_id',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
             VALUES ($1, $2, $3, $4, NOW()) RETURNING *`,
            [conversacion_id, usuario_id, texto || '🎤 Mensaje de voz', audio_url]
        );

        // 🔥 EMITIR POR WEBSOCKET
        global.broadcast(conversacion_id, {
            tipo: 'nuevo_mensaje',
            mensaje: result.rows[0],
        });

        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('Error al guardar audio:', error);
        res.status(500).json({ error: error.message });
    }
});



app.get('/api/conversaciones/:usuario_id', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id } = req.params;
        console.log('Buscando conversaciones para usuario:', usuario_id);
        console.log('>>> 🔐 Usuario autenticado (token):', req.usuarioAutenticado);

        // 🔥 Verificar que el usuario_id de la URL coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide, rechazando lectura de conversaciones');
            return res.status(403).json({
                error: 'No autorizado para ver conversaciones de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            `SELECT c.*, 
             u1.nombre AS nombre1,
             u2.nombre AS nombre2,
             u1.foto_perfil AS foto_perfil1,
             u2.foto_perfil AS foto_perfil2,
             p.imagen_url AS producto_imagen,
             p.imagen_miniatura AS producto_imagen_miniatura,
             p.precio AS producto_precio,
             p.imagen_destacada AS producto_imagen_destacada,
             p.imagenes_reales AS producto_imagenes_reales,
             p.categoria AS productoCategoria,
             p.descripcion AS productoDescripcion,
             p.direccion AS productoDireccion,
             (SELECT texto FROM mensajes_app WHERE conversacion_id = c.id ORDER BY fecha DESC LIMIT 1) AS ultimo_mensaje,
             (SELECT fecha FROM mensajes_app WHERE conversacion_id = c.id ORDER BY fecha DESC LIMIT 1) AS ultima_fecha,
             (SELECT usuario_id FROM mensajes_app WHERE conversacion_id = c.id ORDER BY fecha DESC LIMIT 1) AS ultimo_mensaje_usuario_id,
             CASE 
               WHEN c.usuario1_id = $1 THEN c.ultimo_leido_usuario1
               ELSE c.ultimo_leido_usuario2
             END AS mi_ultimo_leido,
             CASE 
               WHEN c.usuario1_id = $1 THEN c.ultimo_leido_usuario2
               ELSE c.ultimo_leido_usuario1
             END AS su_ultimo_leido
             FROM conversaciones_app c
             LEFT JOIN usuarios u1 ON c.usuario1_id = u1.uid
             LEFT JOIN usuarios u2 ON c.usuario2_id = u2.uid
             LEFT JOIN productos_app p ON c.producto_id = p.id
             WHERE (c.usuario1_id = $1 OR c.usuario2_id = $1)
               AND NOT EXISTS (
                 SELECT 1 FROM conversaciones_ocultas co
                 WHERE co.conversacion_id = c.id 
                   AND co.usuario_id = $1
                   AND (
                     SELECT MAX(fecha) FROM mensajes_app 
                     WHERE conversacion_id = c.id
                   ) <= co.fecha_ocultado
               )`,
            [usuario_id]
        );
        console.log('Conversaciones encontradas:', result.rows.length);
        res.json(result.rows);
    } catch (error) {
        console.error('Error al obtener conversaciones:', error);
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/conversaciones', verificarTokenFirebase, async (req, res) => {
    try {
        console.log('>>> 1. POST /api/conversaciones recibido');
        const { usuario1_id, usuario2_id, producto_nombre, producto_id, producto_imagen } = req.body;

        console.log('>>> 🔐 Usuario autenticado (token):', req.usuarioAutenticado);
        console.log('>>> 🔐 Usuario del body (usuario1_id):', usuario1_id);

        // 🔥 Verificar que el usuario1_id del body sea el usuario autenticado
        // (quien crea el chat debe ser uno de los dos participantes, y ese es usuario1_id)
        if (usuario1_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/conversaciones');
            return res.status(403).json({
                error: 'No autorizado para crear conversaciones a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 BUSCAR SI YA EXISTE UNA CONVERSACIÓN ENTRE ESTOS DOS USUARIOS PARA ESTE PRODUCTO
        const existente = await pool.query(
            `SELECT * FROM conversaciones_app 
             WHERE producto_id = $1
               AND ((usuario1_id = $2 AND usuario2_id = $3)
                    OR (usuario1_id = $3 AND usuario2_id = $2))
             ORDER BY id DESC
             LIMIT 1`,
            [producto_id, usuario1_id, usuario2_id]
        );

        if (existente.rows.length > 0) {
            console.log('>>> ✅ CONVERSACIÓN YA EXISTE, ID:', existente.rows[0].id);

            // 🔥 NO BORRAR conversaciones_ocultas
            // El chat debe seguir oculto si el usuario lo borró.
            // El chat reaparece en la lista cuando llega un mensaje nuevo.

            return res.status(201).json(existente.rows[0]);
        }

        // 🔥 SI NO EXISTE, CREARLA
        let vendedor_id = null;
        if (producto_id) {
            const productResult = await pool.query(
                'SELECT vendedor_id FROM productos_app WHERE id = $1',
                [producto_id]
            );
            if (productResult.rows.length > 0) {
                vendedor_id = productResult.rows[0].vendedor_id;
            }
        }
        
        const result = await pool.query(
            `INSERT INTO conversaciones_app (usuario1_id, usuario2_id, fecha_creacion, producto_nombre, producto_id, producto_imagen, vendedor_id) 
             VALUES ($1, $2, NOW(), $3, $4, $5, $6) RETURNING *`,
            [usuario1_id, usuario2_id, producto_nombre || '', producto_id, producto_imagen || '', vendedor_id]
        );
        console.log('>>> 5. CONVERSACIÓN NUEVA CREADA, ID:', result.rows[0].id);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('>>> 6. ERROR:', error);
        res.status(500).json({ error: error.message });
    }
});
app.post('/api/favoritos', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id, producto_id } = req.body;
        
        console.log('>>> AGREGANDO FAVORITO - producto:', producto_id);

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/favoritos');
            return res.status(403).json({
                error: 'No autorizado para agregar favoritos a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }
        
        await pool.query(
            'INSERT INTO productos_favoritos (usuario_id, producto_id) VALUES ($1, $2::text)',
            [usuario_id, producto_id]
        );
        
        const result = await pool.query(
            'UPDATE productos_app SET likes = COALESCE(likes, 0) + 1 WHERE id = $1 RETURNING likes',
            [producto_id]
        );
        
        console.log('>>> NUEVO LIKES:', result.rows[0]);
        
        res.json({ success: true, likes: result.rows[0]?.likes });
    } catch (error) {
        console.error('Error al agregar favorito:', error);
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/favoritos', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id, producto_id } = req.body;
        
        console.log('>>> ELIMINANDO FAVORITO - producto:', producto_id);

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en DELETE /api/favoritos');
            return res.status(403).json({
                error: 'No autorizado para quitar favoritos a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }
        
        await pool.query(
            'DELETE FROM productos_favoritos WHERE usuario_id = $1 AND producto_id::text = $2',
            [usuario_id, producto_id]
        );
        
        const result = await pool.query(
            'UPDATE productos_app SET likes = likes - 1 WHERE id = $1 AND likes > 0 RETURNING likes',
            [producto_id]
        );
        
        console.log('>>> NUEVO LIKES:', result.rows[0]);
        
        res.json({ success: true, likes: result.rows[0]?.likes });
    } catch (error) {
        console.error('Error al eliminar favorito:', error);
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/favoritos/:usuario_id', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id } = req.params;
        console.log('🔥 Buscando favoritos para usuario:', usuario_id);
        console.log('>>> 🔐 Usuario autenticado (token):', req.usuarioAutenticado);

        // 🔥 Verificar que el usuario_id de la URL coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en GET /api/favoritos/:usuario_id');
            return res.status(403).json({
                error: 'No autorizado para ver favoritos de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            `SELECT 
                p.*, 
                u.nombre AS vendedor_nombre, 
                u.foto_perfil AS vendedor_foto
             FROM productos_app p
             JOIN productos_favoritos f ON p.id::text = f.producto_id
             LEFT JOIN usuarios u ON p.vendedor_id = u.uid
             WHERE f.usuario_id = $1
               AND p.estado_moderacion = 'aprobado'
               AND COALESCE(p.vendido, FALSE) = FALSE`,
            [usuario_id]
        );
        
        console.log('✅ Productos favoritos encontrados:', result.rows.length);
        res.json(result.rows);
    } catch (error) {
        console.error('❌ Error al obtener favoritos:', error);
        res.status(500).json({ error: error.message });
    }
});
// ===== VERIFICAR SI LA FOTO DE PERFIL ES UN ROSTRO HUMANO CLARO =====
async function verificarFotoPerfilConDeepSeek(imagenPath) {
    try {
        const fullPath = path.join(__dirname, imagenPath.replace(/^\//, ''));
        if (!fs.existsSync(fullPath)) {
            console.log('>>> ⚠️ Foto no encontrada:', fullPath);
            return { esRostro: false, motivo: 'Archivo no encontrado' };
        }

        const imageBuffer = fs.readFileSync(fullPath);

        let processedBuffer = imageBuffer;
        const ext = path.extname(fullPath).toLowerCase();
        if (ext === '.avif') {
            processedBuffer = await sharp(imageBuffer).jpeg({ quality: 75 }).toBuffer();
        }

        const resizedBuffer = await sharp(processedBuffer)
            .resize(600, 600, { fit: 'inside', withoutEnlargement: true })
            .jpeg({ quality: 80 })
            .toBuffer();
        const imageBase64 = resizedBuffer.toString('base64');

        const prompt = `Analiza esta imagen de perfil de un marketplace.

Determina si cumple con estos requisitos:
1. Debe ser el ROSTRO de un SER HUMANO real.
2. El rostro debe verse con CLARIDAD (buena iluminación, enfocado, reconocible).
3. NO debe ser: un paisaje, un animal, un logo, un dibujo/anime, un objeto, una foto grupal donde no se distingue un rostro principal, ni una foto borrosa/oscura.

RESPONDE ÚNICAMENTE CON ESTE JSON (sin texto adicional):
{"esRostro": true/false, "motivo": "explicación breve si es false"}`;

        const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;
        const response = await axios.post(
            'https://api.deepseek.com/v1/chat/completions',
            {
                model: 'deepseek-v4-flash-vision-exp',
                messages: [
                    {
                        role: 'user',
                        content: [
                            { type: 'text', text: prompt },
                            {
                                type: 'image_url',
                                image_url: { url: `data:image/jpeg;base64,${imageBase64}` }
                            }
                        ]
                    }
                ],
                temperature: 0,
                max_tokens: 150,
            },
            {
                headers: {
                    'Authorization': `Bearer ${DEEPSEEK_API_KEY}`,
                    'Content-Type': 'application/json'
                },
                timeout: 30000
            }
        );

        const text = response.data.choices[0].message.content;
        console.log('>>> 🤖 DeepSeek (foto perfil):', text);

        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            const resultado = JSON.parse(jsonMatch[0]);
            return {
                esRostro: resultado.esRostro === true,
                motivo: resultado.motivo || ''
            };
        }
        return { esRostro: false, motivo: 'No se pudo analizar la imagen' };
    } catch (error) {
        console.error('>>> ❌ Error verificando foto perfil:', error.message);
        // En error, aprobar para no bloquear el registro
        return { esRostro: true, motivo: '' };
    }
}

// RUTA PARA SUBIR FOTO DE PERFIL
app.post('/api/perfil/foto', verificarTokenFirebase, upload.single('foto'), async (req, res) => {
    console.log('Body:', req.body);
    console.log('File:', req.file);
    console.log('UID:', req.body.uid);

    try {
        const { uid } = req.body;
        const fotoUrl = req.file ? `/uploads/${req.file.filename}` : '';

        // 🔥 Verificar que el uid del body coincida con el del token
        if (uid !== req.usuarioAutenticado) {
            if (req.file) { try { fs.unlinkSync(req.file.path); } catch (_) {} }
            console.log('>>> ❌ UID no coincide en POST /api/perfil/foto');
            return res.status(403).json({
                error: 'No autorizado para modificar la foto de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // Verificar si el usuario existe
        const userCheck = await pool.query('SELECT * FROM usuarios WHERE uid = $1', [uid]);
        console.log('Usuario encontrado:', userCheck.rows);

        if (userCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        // Actualizar foto
        const result = await pool.query(
            'UPDATE usuarios SET foto_perfil = $1 WHERE uid = $2 RETURNING *',
            [fotoUrl, uid]
        );

        console.log('Resultado UPDATE:', result.rows[0]);

        res.json({ fotoUrl, usuario: result.rows[0] });
    } catch (error) {
        console.error('Error al subir foto:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔥 CACHÉ DE TOKENS VERIFICADOS (evita llamar a Firebase en cada request)
// ============================================================
const tokenCache = new Map(); // token → { uid, expira }
const TOKEN_CACHE_MS = 5 * 60 * 1000; // 5 minutos

// 🔥 MIDDLEWARE: verificar token de Firebase (con caché)
async function verificarTokenFirebase(req, res, next) {
    try {
        const authHeader = req.headers.authorization || '';
        const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
        if (!token) {
            return res.status(401).json({ error: 'Token requerido' });
        }

        // 🔥 ¿Ya lo verificamos hace poco? Devolver sin llamar a Firebase
        const cached = tokenCache.get(token);
        if (cached && Date.now() < cached.expira) {
            req.usuarioAutenticado = cached.uid;
            return next();
        }

        // 🔥 No está en caché: verificar con Firebase (tarda ~150 ms)
        const decoded = await getAuth().verifyIdToken(token);
        req.usuarioAutenticado = decoded.uid;
        tokenCache.set(token, {
            uid: decoded.uid,
            expira: Date.now() + TOKEN_CACHE_MS,
        });

        // 🔥 Limpieza: si el caché crece mucho, borrar los expirados
        if (tokenCache.size > 5000) {
            const ahora = Date.now();
            for (const [k, v] of tokenCache.entries()) {
                if (ahora > v.expira) tokenCache.delete(k);
            }
        }

        next();
    } catch (e) {
        console.log('>>> ❌ Token inválido:', e.message);
        console.log('>>> ❌ Token inválido (code):', e.code);
        return res.status(401).json({
            error: 'Token inválido o expirado',
            detalle: e.message,
        });
    }
}

// 🔥 RATE LIMIT SEMANAL POR IP — SOLO PARA REGISTRO
// 3 fotos por semana por IP. La ventana se reinicia 7 días después de la primera.
const rateLimitMap = new Map();
const RATE_LIMIT_WINDOW_MS = 7 * 24 * 60 * 60 * 1000;  // 7 días
const RATE_LIMIT_MAX_REQUESTS = 3;                     // 3 fotos por semana

function rateLimitRegistro(req, res, next) {
    const ip = (req.headers['x-forwarded-for'] || '').split(',')[0].trim()
        || req.socket.remoteAddress
        || 'desconocida';
    const ahora = Date.now();
    let entrada = rateLimitMap.get(ip);

    if (!entrada || ahora > entrada.reset) {
        entrada = { count: 0, reset: ahora + RATE_LIMIT_WINDOW_MS };
        rateLimitMap.set(ip, entrada);
    }

    entrada.count++;

    if (entrada.count > RATE_LIMIT_MAX_REQUESTS) {
        const diasRestantes = Math.ceil((entrada.reset - ahora) / (24 * 60 * 60 * 1000));
        console.log(`>>> 🚫 Rate limit semanal excedido para IP ${ip} (${entrada.count} intentos, quedan ${diasRestantes} días)`);
        return res.status(429).json({
            error: `Llegaste al límite de ${RATE_LIMIT_MAX_REQUESTS} fotos por semana. Probá de nuevo en ${diasRestantes} día${diasRestantes === 1 ? '' : 's'}.`,
            codigo: 'RATE_LIMIT_SEMANAL',
            dias_restantes: diasRestantes
        });
    }
    next();
}

setInterval(() => {
    const ahora = Date.now();
    for (const [ip, entrada] of rateLimitMap.entries()) {
        if (ahora > entrada.reset) rateLimitMap.delete(ip);
    }
}, 24 * 60 * 60 * 1000);


// 🔥 RUTA DE SUBIDA DE FOTO SOLO PARA REGISTRO (con rate limit semanal + token + verificación IA)
app.post('/api/registro/foto',
    rateLimitRegistro,
    verificarTokenFirebase,
    upload.single('foto'),
    async (req, res) => {
    console.log('>>> 📸 /api/registro/foto — Body:', req.body);
    console.log('>>> 📸 File:', req.file);

    try {
        const { uid } = req.body;
        const fotoUrl = req.file ? `/uploads/${req.file.filename}` : '';

        if (!req.file) {
            return res.status(400).json({ error: 'No se subió foto' });
        }

        // 🔥 Verificar que el uid del body coincida con el del token
        if (uid !== req.usuarioAutenticado) {
            try { fs.unlinkSync(req.file.path); } catch (_) {}
            return res.status(403).json({ error: 'No autorizado para modificar este perfil' });
        }

        const userCheck = await pool.query('SELECT * FROM usuarios WHERE uid = $1', [uid]);
        if (userCheck.rows.length === 0) {
            try { fs.unlinkSync(req.file.path); } catch (_) {}
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        // Verificar con DeepSeek
        const verificacion = await verificarFotoPerfilConDeepSeek(fotoUrl);
        console.log('>>> 🔍 Verificación foto registro:', verificacion);

        if (!verificacion.esRostro) {
            try { fs.unlinkSync(req.file.path); } catch (_) {}
            return res.status(400).json({
                error: 'La foto no es válida',
                motivo: verificacion.motivo || 'Debe ser una foto clara de tu rostro',
                codigo: 'FOTO_NO_VALIDA'
            });
        }

        const result = await pool.query(
            'UPDATE usuarios SET foto_perfil = $1 WHERE uid = $2 RETURNING *',
            [fotoUrl, uid]
        );

        res.json({ fotoUrl, usuario: result.rows[0] });
    } catch (error) {
        console.error('Error al subir foto de registro:', error);
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/perfil/foto/:uid', async (req, res) => {
    try {
        const { uid } = req.params;
        const result = await pool.query('SELECT foto_perfil FROM usuarios WHERE uid = $1', [uid]);
        res.json({ foto_perfil: result.rows[0]?.foto_perfil || '' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ===== OBTENER EMAIL DEL VENDEDOR =====
app.get('/api/perfil/email/:uid', async (req, res) => {
    try {
        const { uid } = req.params;
        const result = await pool.query('SELECT email FROM usuarios WHERE uid = $1', [uid]);
        res.json({ email: result.rows[0]?.email || '' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// RUTA PARA GEOLOCALIZACIÓN (convertir coordenadas a provincia y cantón)
// 🔥 CACHÉ DE GEOCODIFICACIÓN EN MEMORIA
const _cacheGeocode = {};

app.get('/api/geocode/:lat/:lng', async (req, res) => {
    try {
        const { lat, lng } = req.params;
        const latR = parseFloat(lat).toFixed(3);
        const lngR = parseFloat(lng).toFixed(3);
        const key = `${latR},${lngR}`;

        // 🔥 SI YA ESTÁ EN CACHÉ, NO LLAMAR A NOMINATIM
        if (_cacheGeocode[key]) {
            console.log('>>> 📦 Geocode caché:', key);
            return res.json(_cacheGeocode[key]);
        }

        // 🔥 BUSCAR EN BD (si algún producto ya tiene esa dirección)
        const bdResult = await pool.query(
            `SELECT provincia, canton FROM productos_app 
             WHERE direccion LIKE $1 AND provincia IS NOT NULL AND provincia != ''
             LIMIT 1`,
            [`%${latR}%`]
        );

        if (bdResult.rows.length > 0) {
            console.log('>>> 🗄️ Geocode desde BD:', bdResult.rows[0]);
            _cacheGeocode[key] = bdResult.rows[0];
            return res.json(bdResult.rows[0]);
        }

        // 🔥 SI NO, LLAMAR A NOMINATIM
        const response = await axios.get(
            `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json&addressdetails=1&zoom=18`,
            {
                headers: {
                    'User-Agent': 'MiMarketplaceCR/1.0 (https://mimarketplace.com)'
                }
            }
        );
        const address = response.data.address;
        
        const provincia = address.state || address.region || address.province || '';
        const canton = address.county || address.city || address.town || address.municipality || '';
        
        const resultado = { provincia, canton };
        _cacheGeocode[key] = resultado;
        res.json(resultado);
    } catch (error) {
        console.error('Error al geocodificar:', error.response?.data || error.message);
        // 🔥 DEVOLVER VACÍO PARA NO ROMPER
        res.json({ provincia: '', canton: '' });
    }
});
app.get('/api/mensajes/:conversacion_id', verificarTokenFirebase, async (req, res) => {
    try {
        const { conversacion_id } = req.params;
        const usuario_id = req.usuarioAutenticado; // 🔥 del token, no del query

        // 1. OBTENER LA CONVERSACIÓN
        const convResult = await pool.query(
            'SELECT * FROM conversaciones_app WHERE id = $1',
            [conversacion_id]
        );
        if (convResult.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }

        // 🔥 Verificar que el usuario autenticado sea PARTE de la conversación
        const convData = convResult.rows[0];
        if (convData.usuario1_id !== usuario_id && convData.usuario2_id !== usuario_id) {
            console.log('>>> ❌ Intento de leer mensajes ajenos. User:', usuario_id, '| Conv:', conversacion_id);
            return res.status(403).json({
                error: 'No autorizado para ver los mensajes de esta conversación',
                codigo: 'NO_ES_PARTE_DE_LA_CONVERSACION'
            });
        }

        // 🔥 SI EL CHAT ESTÁ BLOQUEADO, DEVOLVER LISTA VACÍA
        if (convResult.rows[0].chat_bloqueado === true) {
            return res.json([]);
        }

        const conv = convResult.rows[0];
        const otroUsuarioId = conv.usuario1_id === usuario_id ? conv.usuario2_id : conv.usuario1_id;

        // 2. VERIFICAR SI EL OTRO USUARIO ESTÁ BLOQUEADO
        const bloqueoResult = await pool.query(
            'SELECT * FROM bloqueos WHERE usuario_bloquea = $1 AND usuario_bloqueado = $2',
            [usuario_id, otroUsuarioId]
        );

        // 3. OBTENER FECHA DE ÚLTIMO OCULTAMIENTO (si existe)
        const ocultoResult = await pool.query(
            `SELECT fecha_ocultado FROM conversaciones_ocultas 
             WHERE conversacion_id = $1 AND usuario_id = $2`,
            [conversacion_id, usuario_id]
        );
        const fechaOcultado = ocultoResult.rows.length > 0 
            ? ocultoResult.rows[0].fecha_ocultado 
            : null;

        // 4. CONSTRUIR QUERY
        let query = 'SELECT * FROM mensajes_app WHERE conversacion_id = $1';
        const params = [conversacion_id];
        let paramIndex = 2;

        if (bloqueoResult.rows.length > 0) {
            query += ` AND usuario_id != $${paramIndex}`;
            params.push(otroUsuarioId);
            paramIndex++;
        }

        query += ` AND id NOT IN (
            SELECT mensaje_id FROM mensajes_ocultos WHERE usuario_id = $${paramIndex}
        )`;
        params.push(usuario_id);
        paramIndex++;

        // 🔥 FILTRAR MENSAJES ANTERIORES AL ÚLTIMO OCULTAMIENTO
        if (fechaOcultado) {
            query += ` AND fecha > $${paramIndex}`;
            params.push(fechaOcultado);
            paramIndex++;
        }

        query += ' ORDER BY fecha ASC';

        const result = await pool.query(query, params);
        res.json(result.rows);

    } catch (error) {
        console.error('Error al obtener mensajes:', error);
        res.status(500).json({ error: error.message });
    }
});

// RUTA PARA CREAR USUARIO
app.post('/api/usuarios', verificarTokenFirebase, async (req, res) => {
    try {
        const { uid, email, nombre, telefono, acepta_recoleccion } = req.body;
        console.log('>>> Creando usuario:', { uid, email, nombre, telefono, acepta_recoleccion });

        // 🔥 Verificar que el uid del body coincida con el del token
        if (uid !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/usuarios');
            return res.status(403).json({
                error: 'No autorizado para crear/modificar a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            `INSERT INTO usuarios (uid, email, nombre, telefono, acepta_recoleccion) 
             VALUES ($1, $2, $3, $4, $5) 
             ON CONFLICT (uid) DO UPDATE SET 
             email = EXCLUDED.email, 
             nombre = EXCLUDED.nombre, 
             telefono = EXCLUDED.telefono,
             acepta_recoleccion = EXCLUDED.acepta_recoleccion
             RETURNING *`,
            [uid, email, nombre, telefono, acepta_recoleccion || false]
        );
        console.log('>>> Usuario creado:', result.rows[0]);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('>>> Error al crear usuario:', error);
        res.status(500).json({ error: error.message });
    }
});


// 🔥 FIJAR/DESFIJAR CONVERSACIÓN
app.put('/api/conversaciones/:id/fijar', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;
        const { fijada } = req.body;

        // 🔥 Verificar que el usuario autenticado sea PARTE de la conversación
        const convCheck = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [id]
        );
        if (convCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }
        const convData = convCheck.rows[0];
        if (convData.usuario1_id !== req.usuarioAutenticado && convData.usuario2_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de fijar conversación ajena. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para fijar esta conversación',
                codigo: 'NO_ES_PARTE_DE_LA_CONVERSACION'
            });
        }

        const result = await pool.query(
            `UPDATE conversaciones_app 
             SET fijada = $1 
             WHERE id = $2 
             RETURNING *`,
            [fijada === true, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }

        console.log(`>>> 📌 Conversación ${id} ${fijada ? 'fijada' : 'desfijada'}`);
        res.json({ success: true, conversacion: result.rows[0] });
    } catch (error) {
        console.error('Error al fijar conversación:', error);
        res.status(500).json({ error: error.message });
    }
});

// 🔥 OBTENER ESTADO DE BLOQUEO DE LA CONVERSACIÓN
app.get('/api/conversaciones/:id/estado-bloqueo', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            `SELECT chat_bloqueado, cerrado_por_escudo 
             FROM conversaciones_app WHERE id = $1`,
            [id]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }
        res.json({
            chat_bloqueado: result.rows[0].chat_bloqueado === true,
            cerrado_por_escudo: result.rows[0].cerrado_por_escudo === true,
        });
    } catch (error) {
        console.error('Error al obtener estado de bloqueo:', error);
        res.status(500).json({ error: error.message });
    }
});

// 🔥 OCULTAR CONVERSACIÓN COMPLETA PARA UN USUARIO
app.post('/api/conversaciones/:id/ocultar', verificarTokenFirebase, async (req, res) => {
    console.log('>>> 🔥🔥🔥 ENDPOINT /ocultar LLAMADO - ID:', req.params.id, 'usuario:', req.body.usuario_id);
    try {
        const { id } = req.params;
        const { usuario_id } = req.body;

        if (!usuario_id) {
            return res.status(400).json({ error: 'usuario_id requerido' });
        }

        // 🔥 Verificar que el usuario_id coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en /ocultar');
            return res.status(403).json({
                error: 'No autorizado para ocultar conversaciones de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 Verificar que el usuario autenticado sea PARTE de la conversación
        const convCheck = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [id]
        );
        if (convCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }
        const convData = convCheck.rows[0];
        if (convData.usuario1_id !== req.usuarioAutenticado && convData.usuario2_id !== req.usuarioAutenticado) {
            return res.status(403).json({
                error: 'No autorizado para ocultar esta conversación',
                codigo: 'NO_ES_PARTE_DE_LA_CONVERSACION'
            });
        }

        // 1. MARCAR COMO OCULTA PARA ESTE USUARIO CON FECHA
        await pool.query(
            `INSERT INTO conversaciones_ocultas (conversacion_id, usuario_id, fecha_ocultado)
             VALUES ($1, $2, NOW())
             ON CONFLICT (conversacion_id, usuario_id) 
             DO UPDATE SET fecha_ocultado = NOW()`,
            [id, usuario_id]
        );

        console.log(`>>> 👁️ Conversación ${id} ocultada para ${usuario_id}`);

        // 2. VERIFICAR SI AMBOS USUARIOS LA OCULTARON
        const convResult = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [id]
        );

        if (convResult.rows.length > 0) {
            const conv = convResult.rows[0];
            const ocultas = await pool.query(
                `SELECT COUNT(*) as total FROM conversaciones_ocultas 
                 WHERE conversacion_id = $1 
                   AND usuario_id IN ($2, $3)`,
                [id, conv.usuario1_id, conv.usuario2_id]
            );

            const ambosOcultaron = parseInt(ocultas.rows[0].total) === 2;

            if (ambosOcultaron) {
                console.log(`>>> 🗑️ AMBOS ocultaron → borrando conversación ${id}`);

                await pool.query('DELETE FROM mensajes_app WHERE conversacion_id = $1', [id]);
                await pool.query('DELETE FROM conversaciones_ocultas WHERE conversacion_id = $1', [id]);
                await pool.query('DELETE FROM conversaciones_app WHERE id = $1', [id]);

                console.log(`>>> ✅ Conversación ${id} eliminada por completo`);
                return res.json({ success: true, eliminada: true });
            }
        }

        res.json({ success: true, eliminada: false });
    } catch (error) {
        console.error('>>> ❌❌❌ ERROR AL OCULTAR:', error.message);
        console.error('>>> ❌❌❌ STACK:', error.stack);
        res.status(500).json({ error: error.message });
    }
});

// RUTA PARA ELIMINAR CONVERSACIÓN
app.delete('/api/conversaciones/:id', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;
        console.log('>>> Eliminando conversación ID:', id);

        // 🔥 Verificar que el usuario autenticado sea PARTE de la conversación
        const convCheck = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [id]
        );
        if (convCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }
        const convData = convCheck.rows[0];
        if (convData.usuario1_id !== req.usuarioAutenticado && convData.usuario2_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de borrar conversación ajena. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para eliminar esta conversación',
                codigo: 'NO_ES_PARTE_DE_LA_CONVERSACION'
            });
        }
        
        // Eliminar mensajes de la conversación
        await pool.query('DELETE FROM mensajes_app WHERE conversacion_id = $1', [id]);
        
        // Eliminar la conversación
        await pool.query('DELETE FROM conversaciones_app WHERE id = $1', [id]);
        
        res.json({ success: true });
    } catch (error) {
        console.error('Error al eliminar conversación:', error);
        res.status(500).json({ error: error.message });
    }
});


// ===== CONTEO DE MENSAJES NO LEÍDOS =====
app.get('/api/conversaciones/no-leidos/:usuario_id', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id } = req.params;

        // 🔥 Verificar que el usuario_id de la URL coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en GET /api/conversaciones/no-leidos/:usuario_id');
            return res.status(403).json({
                error: 'No autorizado para ver mensajes no leídos de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // Buscar conversaciones donde el último mensaje NO es mío
        // y es más reciente que mi última lectura
        const result = await pool.query(
            `SELECT COUNT(*) as total
             FROM conversaciones_app c
             WHERE (c.usuario1_id = $1 OR c.usuario2_id = $1)
               AND EXISTS (
                 SELECT 1 FROM mensajes_app m
                 WHERE m.conversacion_id = c.id
                   AND m.usuario_id != $1
                   AND m.fecha > CASE 
                     WHEN c.usuario1_id = $1 THEN COALESCE(c.ultimo_leido_usuario1, '1970-01-01')
                     ELSE COALESCE(c.ultimo_leido_usuario2, '1970-01-01')
                   END
               )`,
            [usuario_id]
        );

        const total = parseInt(result.rows[0]?.total || 0);
        console.log(`>>> 💬 Mensajes no leídos para ${usuario_id}: ${total}`);
        res.json({ total, hay_nuevos: total > 0 });
    } catch (error) {
        console.error('Error al contar mensajes no leídos:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== MARCAR CONVERSACIÓN COMO LEÍDA =====
app.put('/api/conversaciones/:id/leer', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;
        const { usuario_id } = req.body;

        if (!usuario_id) {
            return res.status(400).json({ error: 'usuario_id requerido' });
        }

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en PUT /api/conversaciones/:id/leer');
            return res.status(403).json({
                error: 'No autorizado para marcar conversaciones de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // Obtener la conversación
        const convResult = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [id]
        );

        if (convResult.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }

        const conv = convResult.rows[0];
        const esUsuario1 = conv.usuario1_id === usuario_id;

        const campo = esUsuario1 ? 'ultimo_leido_usuario1' : 'ultimo_leido_usuario2';

        await pool.query(
            `UPDATE conversaciones_app SET ${campo} = NOW() WHERE id = $1`,
            [id]
        );

        console.log(`>>> ✅ Conversación ${id} marcada como leída por ${usuario_id}`);
        res.json({ success: true });
    } catch (error) {
        console.error('Error al marcar como leída:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== RUTA PARA OBTENER ALERTAS =====
app.get('/api/alertas/:usuario_id', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id } = req.params;

        console.log('>>> 🔔 GET /api/alertas/:usuario_id — URL:', usuario_id, '| Token:', req.usuarioAutenticado);

        // 🔥 Verificar que el usuario_id de la URL coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide, rechazando lectura de alertas');
            return res.status(403).json({
                error: 'No autorizado para ver alertas de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            'SELECT * FROM alertas WHERE usuario_id = $1 ORDER BY fecha DESC',
            [usuario_id]
        );
        res.json(result.rows);
    } catch (error) {
        console.error('Error al obtener alertas:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== RUTA PARA OBTENER CONTEO DE ALERTAS NO LEÍDAS =====
app.get('/api/alertas/no-leidas/:usuario_id', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id } = req.params;

        // 🔥 Verificar que el usuario_id de la URL coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en GET /api/alertas/no-leidas/:usuario_id');
            return res.status(403).json({
                error: 'No autorizado para ver alertas de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            'SELECT COUNT(*) as total FROM alertas WHERE usuario_id = $1 AND leida = FALSE',
            [usuario_id]
        );
        const total = parseInt(result.rows[0]?.total || 0);
        console.log(`>>> 🔔 Alertas no leídas para ${usuario_id}: ${total}`);
        res.json({ total, hay_nuevas: total > 0 });
    } catch (error) {
        console.error('Error al contar alertas no leídas:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== RUTA PARA MARCAR TODAS LAS ALERTAS COMO LEÍDAS =====
app.put('/api/alertas/marcar-leidas/:usuario_id', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id } = req.params;

        // 🔥 Verificar que el usuario_id de la URL coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en PUT /api/alertas/marcar-leidas/:usuario_id');
            return res.status(403).json({
                error: 'No autorizado para marcar alertas de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            'UPDATE alertas SET leida = TRUE WHERE usuario_id = $1 AND leida = FALSE',
            [usuario_id]
        );
        console.log(`>>> ✅ ${result.rowCount} alertas marcadas como leídas para ${usuario_id}`);
        res.json({ success: true, marcadas: result.rowCount });
    } catch (error) {
        console.error('Error al marcar alertas como leídas:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== RUTA PARA OBTENER CONTEO DE ALERTAS NO LEÍDAS =====
app.get('/api/alertas/no-leidas/:usuario_id', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id } = req.params;

        // 🔥 Verificar que el usuario_id de la URL coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en GET /api/alertas/no-leidas/:usuario_id');
            return res.status(403).json({
                error: 'No autorizado para ver alertas de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            'SELECT COUNT(*) as total FROM alertas WHERE usuario_id = $1 AND leida = FALSE',
            [usuario_id]
        );
        const total = parseInt(result.rows[0]?.total || 0);
        console.log(`>>> 🔔 Alertas no leídas para ${usuario_id}: ${total}`);
        res.json({ total, hay_nuevas: total > 0 });
    } catch (error) {
        console.error('Error al contar alertas no leídas:', error);
        res.status(500).json({ error: error.message });
    }
});



// ===== RUTA PARA MARCAR ALERTA COMO LEÍDA =====
app.put('/api/alertas/:id', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;

        // 🔥 Verificar que la alerta pertenezca al usuario autenticado
        const checkResult = await pool.query(
            'SELECT usuario_id FROM alertas WHERE id = $1',
            [id]
        );
        if (checkResult.rows.length === 0) {
            return res.status(404).json({ error: 'Alerta no encontrada' });
        }
        if (checkResult.rows[0].usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de marcar alerta ajena. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para marcar esta alerta',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        await pool.query('UPDATE alertas SET leida = TRUE WHERE id = $1', [id]);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ===== RUTA PARA ELIMINAR TODAS LAS ALERTAS DE UN USUARIO =====
app.delete('/api/alertas/limpiar/:usuario_id', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id } = req.params;

        // 🔥 Verificar que el usuario_id de la URL coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en DELETE /api/alertas/limpiar/:usuario_id');
            return res.status(403).json({
                error: 'No autorizado para limpiar alertas de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        await pool.query('DELETE FROM alertas WHERE usuario_id = $1', [usuario_id]);
        res.json({ success: true, mensaje: 'Todas las alertas eliminadas' });
    } catch (error) {
        console.error('Error al limpiar alertas:', error);
        res.status(500).json({ error: error.message });
    }
});
// ===== RUTA PARA GUARDAR BÚSQUEDAS =====
app.post('/api/busquedas-app', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id, termino } = req.body;
        
        if (!usuario_id || !termino || termino.length < 4) {
            return res.status(400).json({ error: 'Datos inválidos' });
        }

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/busquedas-app');
            return res.status(403).json({
                error: 'No autorizado para guardar búsquedas a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 VERIFICAR SI EL USUARIO ACEPTÓ LA RECOLECCIÓN DE DATOS
        const userResult = await pool.query(
            'SELECT acepta_recoleccion FROM usuarios WHERE uid = $1',
            [usuario_id]
        );

        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        if (!userResult.rows[0].acepta_recoleccion) {
            console.log('>>> ⛔ Usuario NO aceptó recolección de datos:', usuario_id);
            return res.status(403).json({ 
                error: 'No has aceptado la recolección de datos.',
                codigo: 'RECOLECCION_NO_ACEPTADA'
            });
        }

        const result = await pool.query(
            'INSERT INTO busquedas_app (usuario_id, termino) VALUES ($1, $2) RETURNING *',
            [usuario_id, termino]
        );

        console.log('>>> ✅ Búsqueda guardada para usuario con consentimiento:', usuario_id);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('Error al guardar búsqueda:', error);
        res.status(500).json({ error: error.message });
    }
});
// ===== RUTAS DE BLOQUEO =====
app.post('/api/bloquear', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_bloquea, usuario_bloqueado } = req.body;
        
        if (!usuario_bloquea || !usuario_bloqueado) {
            return res.status(400).json({ error: 'Faltan datos' });
        }

        // 🔥 Verificar que el usuario_bloquea coincida con el del token
        if (usuario_bloquea !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/bloquear');
            return res.status(403).json({
                error: 'No autorizado para bloquear a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        if (usuario_bloquea === usuario_bloqueado) {
            return res.status(400).json({ error: 'No puedes bloquearte a ti mismo' });
        }

        const check = await pool.query(
            'SELECT * FROM bloqueos WHERE usuario_bloquea = $1 AND usuario_bloqueado = $2',
            [usuario_bloquea, usuario_bloqueado]
        );

        if (check.rows.length > 0) {
            return res.status(400).json({ error: 'Ya has bloqueado a este usuario' });
        }

        const result = await pool.query(
            'INSERT INTO bloqueos (usuario_bloquea, usuario_bloqueado) VALUES ($1, $2) RETURNING *',
            [usuario_bloquea, usuario_bloqueado]
        );

        res.status(201).json({ 
            success: true, 
            mensaje: 'Usuario bloqueado correctamente',
            bloqueo: result.rows[0] 
        });
    } catch (error) {
        console.error('Error al bloquear:', error);
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/bloquear', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_bloquea, usuario_bloqueado } = req.body;
        
        if (!usuario_bloquea || !usuario_bloqueado) {
            return res.status(400).json({ error: 'Faltan datos' });
        }

        // 🔥 Verificar que el usuario_bloquea coincida con el del token
        if (usuario_bloquea !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en DELETE /api/bloquear');
            return res.status(403).json({
                error: 'No autorizado para desbloquear a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            'DELETE FROM bloqueos WHERE usuario_bloquea = $1 AND usuario_bloqueado = $2 RETURNING *',
            [usuario_bloquea, usuario_bloqueado]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'No habías bloqueado a este usuario' });
        }

        res.json({ success: true, mensaje: 'Usuario desbloqueado correctamente' });
    } catch (error) {
        console.error('Error al desbloquear:', error);
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/bloquear/verificar/:usuario_bloquea/:usuario_bloqueado', async (req, res) => {
    try {
        const { usuario_bloquea, usuario_bloqueado } = req.params;
        
        const result = await pool.query(
            'SELECT * FROM bloqueos WHERE usuario_bloquea = $1 AND usuario_bloqueado = $2',
            [usuario_bloquea, usuario_bloqueado]
        );

        res.json({ bloqueado: result.rows.length > 0 });
    } catch (error) {
        console.error('Error al verificar bloqueo:', error);
        res.status(500).json({ error: error.message });
    }
});
// ===== OBTENER LISTA DE BLOQUEADOS POR USUARIO =====
app.get('/api/bloquear/:usuario_id', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id } = req.params;

        console.log('>>> 🚫 GET /api/bloquear/:usuario_id — URL:', usuario_id, '| Token:', req.usuarioAutenticado);

        // 🔥 Verificar que el usuario_id de la URL coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en GET /api/bloquear/:usuario_id');
            return res.status(403).json({
                error: 'No autorizado para ver bloqueados de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            'SELECT * FROM bloqueos WHERE usuario_bloquea = $1 ORDER BY fecha DESC',
            [usuario_id]
        );

        res.json(result.rows);
    } catch (error) {
        console.error('Error al obtener bloqueados:', error);
        res.status(500).json({ error: error.message });
    }
});
// ===== CALIFICACIONES =====
app.get('/api/calificaciones/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;
        const result = await pool.query(
            `SELECT c.*, u.nombre AS calificador_nombre, u.foto_perfil AS calificador_foto
             FROM calificaciones c
             LEFT JOIN usuarios u ON c.calificador_id = u.uid
             WHERE c.usuario_id = $1
             ORDER BY c.fecha DESC`,
            [usuario_id]
        );
        res.json(result.rows);
    } catch (error) {
        console.error('Error al obtener calificaciones:', error);
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/calificaciones/resumen/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;
        const result = await pool.query(
            `SELECT 
                COUNT(*) as total,
                COALESCE(ROUND(AVG(puntuacion)::numeric, 1), 0) as promedio
             FROM calificaciones
             WHERE usuario_id = $1`,
            [usuario_id]
        );
        res.json({
            total: parseInt(result.rows[0]?.total || 0),
            promedio: parseFloat(result.rows[0]?.promedio || 0)
        });
    } catch (error) {
        console.error('Error al obtener resumen de calificaciones:', error);
        res.status(500).json({ error: error.message });
    }
});


// ===== CALIFICAR DESDE EL CHAT =====
app.post('/api/calificaciones/from-chat', verificarTokenFirebase, async (req, res) => {
    try {
        const { conversacion_id, calificador_id, calificado_id, puntuacion, comentario } = req.body;

        if (!conversacion_id || !calificador_id || !calificado_id || !puntuacion) {
            return res.status(400).json({ error: 'Faltan datos' });
        }

        console.log('>>> 🔐 Calificar desde chat. Usuario autenticado:', req.usuarioAutenticado);
        console.log('>>> 🔐 Calificador del body:', calificador_id);

        // 🔥 Verificar que el calificador_id del body coincida con el del token
        if (calificador_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide, rechazando calificación');
            return res.status(403).json({
                error: 'No autorizado para calificar con este usuario_id',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 1. VERIFICAR QUE LA CONVERSACIÓN EXISTA
        const convResult = await pool.query(
            'SELECT * FROM conversaciones_app WHERE id = $1',
            [conversacion_id]
        );
        if (convResult.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }

        // 2. VERIFICAR QUE EL PRODUCTO EXISTA
        const productoId = convResult.rows[0].producto_id;
        if (!productoId) {
            return res.status(400).json({ error: 'Producto no encontrado' });
        }

        // 3. GUARDAR CALIFICACIÓN
        const result = await pool.query(
            `INSERT INTO calificaciones (usuario_id, calificador_id, producto_id, puntuacion, comentario)
             VALUES ($1, $2, $3, $4, $5)
             ON CONFLICT (calificador_id, producto_id) DO UPDATE 
             SET puntuacion = $4, comentario = $5, fecha = NOW()
             RETURNING *`,
            [calificado_id, calificador_id, productoId, puntuacion, comentario || '']
        );

        // 4. ENVIAR MENSAJE DE CONFIRMACIÓN
        await pool.query(
            `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
             VALUES ($1, $2, $3, $4, NOW())`,
            [
                conversacion_id,
                'SYSTEM',
                `✅ Has calificado al usuario con ${puntuacion} estrellas. ¡Gracias por tu opinión!`,
                ''
            ]
        );

        res.status(201).json({ 
            success: true, 
            calificacion: result.rows[0],
            mensaje: 'Calificación guardada correctamente'
        });
    } catch (error) {
        console.error('Error al calificar desde chat:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== ELIMINAR PRODUCTO =====
app.delete('/api/productos/:id', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;
        const { vendedor_id } = req.body;
        
        console.log('>>> ELIMINAR PRODUCTO ID:', id);
        console.log('>>> VENDEDOR_ID:', vendedor_id);

        console.log('>>> 🔐 Usuario autenticado (token):', req.usuarioAutenticado);
        console.log('>>> 🔐 Vendedor del body:', vendedor_id);

        // 🔥 Verificar que el vendedor_id del body coincida con el del token
        if (vendedor_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide, rechazando');
            return res.status(403).json({
                error: 'No autorizado para eliminar este producto',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        console.log('>>> ✅ Token válido y UID coincide, procediendo a eliminar');

        const checkResult = await pool.query(
            'SELECT * FROM productos_app WHERE id = $1 AND vendedor_id = $2',
            [id, vendedor_id]
        );

        console.log('>>> PRODUCTO ENCONTRADO:', checkResult.rows.length);

        if (checkResult.rows.length === 0) {
            return res.status(404).json({ 
                error: 'Producto no encontrado o no pertenece a este usuario' 
            });
        }

        await pool.query('DELETE FROM productos_app WHERE id = $1', [id]);

        res.json({ 
            success: true, 
            mensaje: 'Producto eliminado correctamente' 
        });
    } catch (error) {
        console.error('Error al eliminar producto:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== MARCAR PRODUCTO COMO VENDIDO =====
app.post('/api/productos/:id/vendido', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;
        const { vendedor_id } = req.body;

        if (!vendedor_id) {
            return res.status(400).json({ error: 'vendedor_id requerido' });
        }

        console.log('>>> 💰 Marcar vendido. Usuario autenticado:', req.usuarioAutenticado);
        console.log('>>> 💰 Vendedor del body:', vendedor_id);

        // 🔥 Verificar que el vendedor_id del body coincida con el del token
        if (vendedor_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en marcar vendido');
            return res.status(403).json({
                error: 'No autorizado para marcar este producto como vendido',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 1. VERIFICAR QUE EL PRODUCTO PERTENEZCA AL VENDEDOR
        const checkResult = await pool.query(
            'SELECT * FROM productos_app WHERE id = $1 AND vendedor_id = $2',
            [id, vendedor_id]
        );

        if (checkResult.rows.length === 0) {
            return res.status(404).json({ error: 'Producto no encontrado o no te pertenece' });
        }

        const producto = checkResult.rows[0];

        if (producto.vendido === true) {
            return res.status(400).json({ error: 'Este producto ya fue marcado como vendido' });
        }

        // 2. MARCAR COMO VENDIDO
        await pool.query(
            `UPDATE productos_app 
             SET vendido = TRUE, fecha_vendido = NOW(), estado = 'vendido'
             WHERE id = $1`,
            [id]
        );

        console.log(`>>> ✅ Producto ${id} marcado como VENDIDO`);

        // 3. BUSCAR TODAS LAS CONVERSACIONES DE ESTE PRODUCTO
        const convResult = await pool.query(
            `SELECT id, usuario1_id, usuario2_id 
             FROM conversaciones_app 
             WHERE producto_id = $1`,
            [id]
        );

        console.log(`>>> 📩 Enviando mensaje a ${convResult.rows.length} conversaciones`);

        // 4. INSERTAR UN MENSAJE EN CADA CONVERSACIÓN
        for (const conv of convResult.rows) {
            await pool.query(
                `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
                 VALUES ($1, 'SYSTEM', $2, '', NOW())`,
                [conv.id, `||ARTICULO_VENDIDO||${producto.nombre}`]
            );
            console.log(`>>> 📩 Mensaje "vendido" insertado en conversación ${conv.id}`);
        }

        res.json({
            success: true,
            mensaje: 'Producto marcado como vendido',
            conversaciones_notificadas: convResult.rows.length,
        });
    } catch (error) {
        console.error('Error al marcar producto como vendido:', error);
        res.status(500).json({ error: error.message });
    }
});
app.post('/api/agenda', verificarTokenFirebase, async (req, res) => {
    console.log('>>> 🔥🔥🔥 VERSIÓN 3 CON productos_lista 🔥🔥🔥');
    try {
        console.log('>>> GUARDANDO EN AGENDA:', req.body);
        
        const { 
            usuario_id, 
            otro_usuario, 
            producto_nombre, 
            ultimo_mensaje, 
            producto_imagen, 
            conversacion_id,
            productos_lista,     // 🔥 NUEVO
            foto_perfil          // 🔥 NUEVO
        } = req.body;

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/agenda');
            return res.status(403).json({
                error: 'No autorizado para guardar en la agenda de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }
        
        console.log('>>> usuario_id:', usuario_id);
        console.log('>>> conversacion_id:', conversacion_id);
        console.log('>>> productos_lista:', productos_lista);
        
        // 🔥 Convertir productos_lista a JSON string
        const productosJson = productos_lista 
            ? JSON.stringify(productos_lista) 
            : null;
        
        // Verificar si ya existe
        const check = await pool.query(
            'SELECT * FROM agenda WHERE usuario_id = $1 AND conversacion_id = $2',
            [usuario_id, conversacion_id]
        );
        
        console.log('>>> EXISTE:', check.rows.length > 0);
        
        if (check.rows.length > 0) {
            // Actualizar
            console.log('>>> ACTUALIZANDO...');
            const result = await pool.query(
                `UPDATE agenda 
                 SET otro_usuario = $1, 
                     producto_nombre = $2, 
                     ultimo_mensaje = $3, 
                     producto_imagen = $4, 
                     productos_lista = $5,
                     foto_perfil = $6,
                     fecha_guardado = NOW()
                 WHERE usuario_id = $7 AND conversacion_id = $8
                 RETURNING *`,
                [otro_usuario, producto_nombre, ultimo_mensaje, producto_imagen, 
                 productosJson, foto_perfil, usuario_id, conversacion_id]
            );
            console.log('>>> ACTUALIZADO:', result.rows[0]);
            res.json(result.rows[0]);
        } else {
            // Insertar
            console.log('>>> INSERTANDO NUEVO...');
            const result = await pool.query(
                `INSERT INTO agenda 
                 (usuario_id, otro_usuario, producto_nombre, ultimo_mensaje, 
                  producto_imagen, conversacion_id, productos_lista, foto_perfil)
                 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                 RETURNING *`,
                [usuario_id, otro_usuario, producto_nombre, ultimo_mensaje, 
                 producto_imagen, conversacion_id, productosJson, foto_perfil]
            );
            console.log('>>> INSERTADO:', result.rows[0]);
            res.status(201).json(result.rows[0]);
        }
    } catch (error) {
        console.error('>>> ERROR EN AGENDA:', error);
        res.status(500).json({ error: error.message });
    }
});


// ===== REGISTRAR VISTA DE PRODUCTO =====
app.post('/api/productos/:id/vista', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;
        const { usuario_id } = req.body;
        const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;

        // 🔥 El usuario_id del body tiene que ser el autenticado (o null para anónimo)
        if (usuario_id !== null && usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/productos/:id/vista');
            return res.status(403).json({
                error: 'No autorizado para registrar vistas a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 1. Insertar vista individual
        await pool.query(
            `INSERT INTO vistas_producto (producto_id, usuario_id, ip, fecha)
             VALUES ($1, $2, $3, NOW())`,
            [id, usuario_id || null, ip]
        );

        // 2. Actualizar contador en productos_app
        await pool.query(
            `UPDATE productos_app SET vistas = COALESCE(vistas, 0) + 1 WHERE id = $1`,
            [id]
        );

        // 3. Actualizar resumen diario
        const today = new Date().toISOString().split('T')[0];
        await pool.query(
            `INSERT INTO vistas_resumen_diario (producto_id, fecha, total_vistas)
             VALUES ($1, $2, 1)
             ON CONFLICT (producto_id, fecha) 
             DO UPDATE SET total_vistas = vistas_resumen_diario.total_vistas + 1`,
            [id, today]
        );

        res.json({ success: true });
    } catch (error) {
        console.error('Error al registrar vista:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== OBTENER ESTADÍSTICAS DE UN PRODUCTO =====
app.get('/api/productos/:id/estadisticas', async (req, res) => {
    try {
        const { id } = req.params;
        const { dias } = req.query; // Últimos N días (default: 30)

        const limiteDias = parseInt(dias) || 30;

        // 1. Total de vistas
        const totalResult = await pool.query(
            `SELECT COALESCE(SUM(total_vistas), 0) as total
             FROM vistas_resumen_diario
             WHERE producto_id = $1`,
            [id]
        );

        // 2. Vistas por día (últimos N días)
        const diarioResult = await pool.query(
            `SELECT fecha, total_vistas
             FROM vistas_resumen_diario
             WHERE producto_id = $1 
               AND fecha >= NOW() - INTERVAL '${limiteDias} days'
             ORDER BY fecha ASC`,
            [id]
        );

        // 3. Ranking de productos (para la gráfica de barras)
        const rankingResult = await pool.query(
            `SELECT p.id, p.nombre, p.imagen_url, 
                    COALESCE(SUM(v.total_vistas), 0) as total_vistas
             FROM productos_app p
             LEFT JOIN vistas_resumen_diario v ON p.id = v.producto_id
             WHERE p.vendedor_id = (SELECT vendedor_id FROM productos_app WHERE id = $1)
             GROUP BY p.id, p.nombre, p.imagen_url
             ORDER BY total_vistas DESC
             LIMIT 20`,
            [id]
        );

        res.json({
            total_vistas: parseInt(totalResult.rows[0]?.total || 0),
            diario: diarioResult.rows,
            ranking: rankingResult.rows
        });
    } catch (error) {
        console.error('Error al obtener estadísticas:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== OBTENER RANKING GENERAL DE PRODUCTOS (TODOS LOS VENDEDORES) =====
app.get('/api/productos/ranking', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT p.id, p.nombre, p.imagen_url, p.vendedor_nombre,
                    COALESCE(SUM(v.total_vistas), 0) as total_vistas
             FROM productos_app p
             LEFT JOIN vistas_resumen_diario v ON p.id = v.producto_id
             WHERE p.estado_moderacion = 'aprobado'
             GROUP BY p.id, p.nombre, p.imagen_url, p.vendedor_nombre
             ORDER BY total_vistas DESC
             LIMIT 50`
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// ===== OBTENER RANKING DE PRODUCTOS MÁS VISTOS DE UN USUARIO =====
app.get('/api/estadisticas/usuario/:usuario_id/ranking', async (req, res) => {
    try {
        const { usuario_id } = req.params;

        console.log('>>> Ranking para usuario:', usuario_id);

        const result = await pool.query(
            `SELECT p.id, p.nombre, p.imagen_url, p.precio, p.vendedor_nombre,
                    COALESCE(COUNT(v.id), 0) as total_vistas
             FROM productos_app p
             LEFT JOIN vistas_producto v ON p.id = v.producto_id
             WHERE p.vendedor_id = $1
               AND p.estado_moderacion = 'aprobado'
             GROUP BY p.id, p.nombre, p.imagen_url, p.precio, p.vendedor_nombre
             ORDER BY total_vistas DESC
             LIMIT 20`,
            [usuario_id]
        );

        console.log('>>> Productos encontrados:', result.rows.length);
        res.json(result.rows);
    } catch (error) {
        console.error('Error al obtener ranking de productos:', error);
        res.status(500).json({ error: error.message });
    }
});
// ===== OBTENER TODAS LAS CONVERSACIONES DE UN USUARIO CON DETALLE DE PRODUCTOS =====



// ===== GUARDAR AGENDA (CADA PRODUCTO ES UN REGISTRO SEPARADO) =====
app.post('/api/agenda/guardar-todas', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id, conversaciones } = req.body;

        console.log('>>> Agenda - Recibidas:', conversaciones.length);

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/agenda/guardar-todas');
            return res.status(403).json({
                error: 'No autorizado para modificar la agenda de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        if (!conversaciones || conversaciones.length === 0) {
            return res.status(400).json({ error: 'No hay conversaciones' });
        }

        // ELIMINAR AGENDA ANTERIOR DEL USUARIO
        await pool.query('DELETE FROM agenda WHERE usuario_id = $1', [usuario_id]);

        // INSERTAR CADA CONVERSACIÓN COMO UN REGISTRO SEPARADO
        const resultados = [];
        for (const conv of conversaciones) {
            const esUsuario1 = conv.usuario1_id === usuario_id;
            const vendedorNombre = esUsuario1 ? conv.nombre2 : conv.nombre1;

            const result = await pool.query(
                `INSERT INTO agenda 
                    (usuario_id, otro_usuario, producto_nombre, ultimo_mensaje, producto_imagen, 
                     conversacion_id, producto_id, vendedor_id, fecha_guardado)
                 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
                 RETURNING *`,
                [
                    usuario_id,
                    vendedorNombre || 'Vendedor',
                    conv.producto_nombre || 'Producto',
                    conv.ultimo_mensaje || 'Sin mensajes',
                    conv.producto_imagen || '',
                    conv.id,  // UN SOLO ID
                    conv.producto_id || 0,
                    conv.vendedor_id || ''
                ]
            );
            resultados.push(result.rows[0]);
            console.log('  ✅ Insertado:', conv.producto_nombre);
        }

        console.log('>>> Agenda - TOTAL insertados:', resultados.length);

        res.status(201).json({
            success: true,
            message: `${resultados.length} productos guardados en agenda`,
            data: resultados
        });
    } catch (error) {
        console.error('❌ Error:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== OBTENER AGENDA DE UN USUARIO =====
app.get('/api/agenda/:usuario_id', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id } = req.params;

        console.log('>>> Agenda - OBTENIENDO para usuario:', usuario_id);
        console.log('>>> 🔐 Usuario autenticado (token):', req.usuarioAutenticado);

        // 🔥 Verificar que el usuario_id de la URL coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en GET /api/agenda/:usuario_id');
            return res.status(403).json({
                error: 'No autorizado para ver agenda de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            `SELECT *, 
                    productos_lista
             FROM agenda 
             WHERE usuario_id = $1 
             ORDER BY fecha_guardado DESC`,
            [usuario_id]
        );

        console.log(`>>> Agenda - Registros encontrados: ${result.rows.length}`);

        const agendaConProductos = result.rows.map(item => {
            let productos = [];
            try {
                if (item.productos_lista) {
                    productos = JSON.parse(item.productos_lista);
                    console.log(`  - ${item.otro_usuario}: ${productos.length} productos (desde lista)`);
                } else if (item.producto_nombre) {
                    const nombres = item.producto_nombre.split(',').map(p => p.trim());
                    const ids = item.producto_id?.split(',') || [];
                    const imagenes = item.producto_imagen?.split(',') || [];
                    productos = nombres.map((nombre, i) => ({
                        producto_nombre: nombre,
                        producto_id: ids[i] || 0,
                        producto_imagen: imagenes[i] || ''
                    }));
                    console.log(`  - ${item.otro_usuario}: ${productos.length} productos (desde nombres)`);
                }
            } catch (e) {
                console.log(`  - Error al parsear ${item.otro_usuario}:`, e.message);
            }
            return {
                ...item,
                productos: productos,
                cantidad_productos: productos.length
            };
        });

        res.json(agendaConProductos);
    } catch (error) {
        console.error('Error al obtener agenda:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== ELIMINAR DE AGENDA =====
app.delete('/api/agenda/:id', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;

        // 🔥 Verificar que el registro pertenezca al usuario autenticado
        const checkResult = await pool.query(
            'SELECT usuario_id FROM agenda WHERE id = $1',
            [id]
        );

        if (checkResult.rows.length === 0) {
            return res.status(404).json({ error: 'Registro de agenda no encontrado' });
        }

        if (checkResult.rows[0].usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de borrar registro de agenda ajena. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para eliminar registros de la agenda de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        await pool.query('DELETE FROM agenda WHERE id = $1', [id]);

        res.json({ success: true });
    } catch (error) {
        console.error('Error al eliminar de agenda:', error);
        res.status(500).json({ error: error.message });
    }
});
// ===== VERIFICAR SI IMAGEN FUE GENERADA POR IA =====
app.post('/api/verificar-imagen-ia', upload.single('imagen'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No se subió imagen' });
        }

        const imagePath = req.file.path;
        console.log('>>> Verificando imagen IA:', imagePath);
        
        // 🔥 USAR GEMINI PARA VERIFICAR
        const resultado = await verificarImagenConGemini(imagePath);
        
        // Limpiar archivo temporal
        fs.unlinkSync(imagePath);

        console.log('>>> Resultado verificación IA:', resultado);

        res.json({ 
            esIA: resultado.esIA,
            confianza: resultado.confianza || 0.8
        });
    } catch (error) {
        console.error('Error al verificar IA:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== FUNCIÓN PARA VERIFICAR IMAGEN CON GEMINI =====
async function verificarImagenConGemini(imagenPath) {
    try {
        const fullPath = path.join(__dirname, imagenPath.replace(/^\//, ''));
        console.log('>>> Leyendo imagen desde:', fullPath);

        if (!fs.existsSync(fullPath)) {
            console.log('⚠️ Archivo no encontrado');
            return { esIA: false, confianza: 0 };
        }

        const imageBuffer = fs.readFileSync(fullPath);
        const imageBase64 = imageBuffer.toString('base64');

                // Detectar mime type por extensión (NO confiar en multer)
        const ext = path.extname(fullPath).toLowerCase();
        let mimeType = 'image/jpeg';
        if (ext === '.png') mimeType = 'image/png';
        if (ext === '.webp') mimeType = 'image/webp';
        if (ext === '.gif') mimeType = 'image/gif';
        if (ext === '.bmp') mimeType = 'image/bmp';
        if (ext === '.tiff' || ext === '.tif') mimeType = 'image/tiff';
        if (ext === '.avif') mimeType = 'image/avif';
        if (ext === '.jpg' || ext === '.jpeg') mimeType = 'image/jpeg';
        console.log('>>> MIME TYPE DETECTADO:', mimeType);

        const prompt = `Eres un detector de imágenes generadas por IA. Analiza esta imagen y determina si fue creada por inteligencia artificial.

RESPONDE ÚNICAMENTE CON UN JSON VÁLIDO (sin texto adicional):
{
  "esIA": true/false,
  "confianza": 0.0-1.0
}`;

        const GEMINI_KEY = process.env.GEMINI_API_KEY;
        const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_KEY}`;

        const response = await axios.post(url, {
            contents: [{
                parts: [
                    { text: prompt },
                    { inline_data: { mime_type: mimeType, data: imageBase64 } }
                ]
            }]
        }, {
            headers: { 'Content-Type': 'application/json' },
            timeout: 30000
        });

        const text = response.data.candidates?.[0]?.content?.parts?.[0]?.text || '';
        console.log('>>> Respuesta de verificación IA:', text);

        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            const resultado = JSON.parse(jsonMatch[0]);
            return {
                esIA: resultado.esIA === true,
                confianza: resultado.confianza || 0.8
            };
        }

        return { esIA: false, confianza: 0 };
    } catch (error) {
        console.error('Error en verificarImagenConGemini:', error.message);
        if (error.response) {
            console.error('>>> Detalles:', error.response.status, error.response.data);
        }
        return { esIA: false, confianza: 0 };
    }
}
// ===== EDITAR PRODUCTO (CON IMAGEN) =====
app.put('/api/productos/:id', verificarTokenFirebase, upload.single('imagen'), async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, descripcion, precio, categoria, subcategoria, direccion, vendedor_id } = req.body;
        
        console.log('>>> EDITANDO PRODUCTO ID:', id);
        console.log('>>> NOMBRE:', nombre);
        console.log('>>> IMAGEN RECIBIDA:', req.file ? 'SÍ' : 'NO');
        console.log('>>> 🔐 Usuario autenticado (token):', req.usuarioAutenticado);
        console.log('>>> 🔐 Vendedor del body:', vendedor_id);
        
        // 🔥 Verificar que el vendedor_id del body coincida con el del token
        if (vendedor_id !== req.usuarioAutenticado) {
            if (req.file) { try { fs.unlinkSync(req.file.path); } catch (_) {} }
            console.log('>>> ❌ UID no coincide, rechazando');
            return res.status(403).json({
                error: 'No autorizado para editar este producto',
                codigo: 'UID_NO_COINCIDE'
            });
        }
        
        // 1. OBTENER EL PRODUCTO ACTUAL
        const productoActual = await pool.query(
            'SELECT * FROM productos_app WHERE id = $1',
            [id]
        );
        
        if (productoActual.rows.length === 0) {
            if (req.file) { try { fs.unlinkSync(req.file.path); } catch (_) {} }
            return res.status(404).json({ error: 'Producto no encontrado' });
        }

        // 🔥 Verificar que el producto pertenezca al usuario autenticado
        if (productoActual.rows[0].vendedor_id !== req.usuarioAutenticado) {
            if (req.file) { try { fs.unlinkSync(req.file.path); } catch (_) {} }
            console.log('>>> ❌ Intento de editar producto ajeno. Dueño:', productoActual.rows[0].vendedor_id, '| Atacante:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para editar este producto',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        console.log('>>> ✅ Producto pertenece al usuario, procediendo a editar');
        
        // 2. CONSTRUIR QUERY DINÁMICA
        let query = 'UPDATE productos_app SET ';
        const params = [];
        let paramIndex = 1;
        
        // Campos a actualizar (solo los que vienen en el body)
        if (nombre !== undefined && nombre !== '') {
            query += `nombre = $${paramIndex}, `;
            params.push(nombre);
            paramIndex++;
        }
        
        if (descripcion !== undefined) {
            query += `descripcion = $${paramIndex}, `;
            params.push(descripcion);
            paramIndex++;
        }
        
        if (precio !== undefined && precio !== '') {
            query += `precio = $${paramIndex}, `;
            params.push(parseFloat(precio));
            paramIndex++;
        }
        
        if (categoria !== undefined && categoria !== '') {
            query += `categoria = $${paramIndex}, `;
            params.push(categoria);
            paramIndex++;
        }
        
        if (subcategoria !== undefined) {
            query += `subcategoria = $${paramIndex}, `;
            params.push(subcategoria);
            paramIndex++;
        }
        
        if (direccion !== undefined) {
            query += `direccion = $${paramIndex}, `;
            params.push(direccion);
            paramIndex++;
        }
        
        // 3. Si hay nueva imagen, actualizarla
        if (req.file) {
            const imagen_url = `/uploads/${req.file.filename}`;
            query += `imagen_url = $${paramIndex}, `;
            params.push(imagen_url);
            paramIndex++;
            
            // 🔥 Si es la imagen principal, actualizar también imagen_destacada?
            // (opcional, depende de tu lógica)
        }
        
        // Quitar la última coma y espacio
        query = query.slice(0, -2);
        query += ` WHERE id = $${paramIndex} RETURNING *`;
        params.push(id);
        
        console.log('>>> QUERY:', query);
        console.log('>>> PARAMS:', params);
        
        // 4. EJECUTAR UPDATE
        const result = await pool.query(query, params);
        
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Producto no encontrado' });
        }
        
        console.log('>>> PRODUCTO ACTUALIZADO:', result.rows[0]);
        res.json(result.rows[0]);
        
    } catch (error) {
        console.error('Error al actualizar producto:', error);
        res.status(500).json({ error: error.message });
    }
});
// En tu server.js
app.post('/api/denuncias', verificarTokenFirebase, async (req, res) => {
    try {
        const { denunciante_id, denunciado_id, producto_id, motivo } = req.body;
        
        if (!denunciante_id || !denunciado_id || !producto_id) {
            return res.status(400).json({ error: 'Faltan datos' });
        }

        console.log('>>> 🚨 Denuncia. Usuario autenticado:', req.usuarioAutenticado);
        console.log('>>> 🚨 Denunciante del body:', denunciante_id);

        // 🔥 Verificar que el denunciante_id coincida con el del token
        if (denunciante_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/denuncias');
            return res.status(403).json({
                error: 'No autorizado para denunciar a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            `INSERT INTO denuncias (denunciante_id, denunciado_id, producto_id, motivo)
             VALUES ($1, $2, $3, $4) RETURNING *`,
            [denunciante_id, denunciado_id, producto_id, motivo || 'Producto sospechoso']
        );

        res.status(201).json({ 
            success: true, 
            mensaje: 'Denuncia enviada correctamente',
            denuncia: result.rows[0]
        });
    } catch (error) {
        console.error('Error al guardar denuncia:', error);
        res.status(500).json({ error: error.message });
    }
});
// ===== ANALIZAR CALIDAD FOTOGRÁFICA CON GEMINI =====
async function analizarCalidadImagen(imagenPath) {
    try {
        const fullPath = path.join(__dirname, imagenPath.replace(/^\//, ''));
        if (!fs.existsSync(fullPath)) {
            console.error('⚠️ Archivo no encontrado:', fullPath);
            return { aprobado: true, motivo: '' };
        }

        const imageBuffer = fs.readFileSync(fullPath);
        const imageBase64 = imageBuffer.toString('base64');

        const ext = path.extname(fullPath).toLowerCase();
        let mimeType = 'image/jpeg';
        if (ext === '.png') mimeType = 'image/png';
        if (ext === '.webp') mimeType = 'image/webp';
        if (ext === '.gif') mimeType = 'image/gif';
        if (ext === '.bmp') mimeType = 'image/bmp';
        if (ext === '.tiff' || ext === '.tif') mimeType = 'image/tiff';
        if (ext === '.avif') mimeType = 'image/avif';
        if (ext === '.jpg' || ext === '.jpeg') mimeType = 'image/jpeg';
        console.log('>>> MIME TYPE DETECTADO (calidad):', mimeType);

        const prompt = `Eres un experto en fotografía y calidad de imagen. Analiza esta imagen y determina si cumple con los requisitos mínimos de calidad para ser publicada en un marketplace.

REQUISITOS DE CALIDAD (OBLIGATORIOS):
- La imagen debe ser NITIDA (no borrosa, no pixelada, con buen enfoque)
- La imagen debe tener BUENA ILUMINACIÓN (no oscura, no con sombras excesivas, no sobreexpuesta)
- El producto debe verse COMPLETO (no cortado, no fuera de foco)
- La imagen debe tener FONDO LIMPIO (no desordenado, no con objetos distractores)
- La resolución debe ser ADECUADA (no menos de 300x300 píxeles)

RESPONDE ÚNICAMENTE CON UN JSON VÁLIDO:
{
  "aprobado": true/false,
  "motivo": "explicación breve del problema si es rechazado, o vacío si es aprobado"
}`;

        const GEMINI_KEY = process.env.GEMINI_API_KEY;
        const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_KEY}`;

        const response = await axios.post(url, {
            contents: [{
                parts: [
                    { text: prompt },
                    { inline_data: { mime_type: mimeType, data: imageBase64 } }
                ]
            }]
        }, {
            headers: { 'Content-Type': 'application/json' },
            timeout: 30000
        });

        const text = response.data.candidates?.[0]?.content?.parts?.[0]?.text || '';
        console.log('>>> Respuesta de análisis de calidad:', text);

        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            const resultado = JSON.parse(jsonMatch[0]);
            return {
                aprobado: resultado.aprobado === true,
                motivo: resultado.motivo || ''
            };
        }

        return { aprobado: true, motivo: '' };
    } catch (error) {
        console.error('Error en analizarCalidadImagen:', error.message);
        if (error.response) {
            console.error('>>> Detalles:', error.response.status, error.response.data);
        }
        return { aprobado: true, motivo: '' };
    }
}
// ===== ANALIZAR IMAGEN COMPLETA CON DEEPSEEK VISION =====
async function analizarImagenCompleta(imagenPath) {
    try {
        console.log('>>> 🚨🚨🚨 DEEPSEEK LLAMADO DESDE analizarImagenCompleta');
        console.log('>>> 🚨 Imagen:', imagenPath);
        const fullPath = path.join(__dirname, imagenPath.replace(/^\//, ''));
        if (!fs.existsSync(fullPath)) {
            console.error('⚠️ Archivo no encontrado:', fullPath);
            return {
                moderacion: { aprobado: true, motivo: '' },
                calidad: { aprobado: true, motivo: '' }
            };
        }

        const imageBuffer = fs.readFileSync(fullPath);
        
        // 🔥 CONVERTIR AVIF A JPEG
        let processedBuffer = imageBuffer;
        const ext = path.extname(fullPath).toLowerCase();
        if (ext === '.avif') {
            console.log('>>> 🔥 AVIF detectado, convirtiendo a JPEG...');
            processedBuffer = await sharp(imageBuffer)
                .jpeg({ quality: 75 })
                .toBuffer();
        }
        
        const resizedBuffer = await sharp(processedBuffer)
            .resize(800, 800, { fit: 'inside', withoutEnlargement: true })
            .jpeg({ quality: 75 })
            .toBuffer();
        const imageBase64 = resizedBuffer.toString('base64');
        const mimeType = 'image/jpeg';

        const prompt = `Eres un moderador de un marketplace. Analiza esta imagen de producto y responde ÚNICAMENTE con este JSON:

{"aprobado": true/false, "motivo": "explicación breve si es rechazado", "calidad": "buena/mala/regular"}

REGLAS:
- Si el producto es un celular, consola de videojuegos, arma, animal vivo, artículo erótico o equipo médico → aprobado: false
- Si la imagen está borrosa, oscura o el producto no se ve completo → calidad: mala
- Si todo está bien → aprobado: true y calidad: buena
- NO agregues texto adicional, SOLO el JSON.`;

        const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;  // ✅ BIEN
        const url = 'https://api.deepseek.com/v1/chat/completions';

        const response = await axios.post(url, {
            model: 'deepseek-v4-flash-vision-exp',
            messages: [
                {
                    role: 'user',
                    content: [
                        { type: 'text', text: prompt },
                        {
                            type: 'image_url',
                            image_url: {
                                url: `data:image/jpeg;base64,${imageBase64}`
                            }
                        }
                    ]
                }
            ],
            temperature: 0.1,
            max_tokens: 300,
        }, {
            headers: {
                'Authorization': `Bearer ${DEEPSEEK_API_KEY}`,
                'Content-Type': 'application/json'
            },
            timeout: 30000
        });

        const text = response.data.choices[0].message.content;
        console.log('>>> Respuesta de DeepSeek (moderación+calidad):', text);

        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            try {
                const resultado = JSON.parse(jsonMatch[0]);
                console.log('>>> ✅ JSON parseado:', resultado);
                return {
                    moderacion: {
                        aprobado: resultado.aprobado === true,
                        motivo: resultado.motivo || ''
                    },
                    calidad: {
                        aprobado: resultado.calidad === 'buena',
                        motivo: resultado.calidad === 'mala' ? 'Calidad de imagen insuficiente' : ''
                    }
                };
            } catch (e) {
                console.log('>>> ❌ Error al parsear JSON:', e.message);
                console.log('>>> Texto recibido:', text);
            }
        }

        console.log('>>> ⚠️ No se encontró JSON, aprobando por defecto');
        return {
            moderacion: { aprobado: true, motivo: '' },
            calidad: { aprobado: true, motivo: '' }
        };
    } catch (error) {
        console.error('Error en analizarImagenCompleta:', error.message);
        if (error.response) {
            console.error('>>> Detalles:', error.response.status, error.response.data);
        }
        return {
            moderacion: { aprobado: false, motivo: 'Error al verificar con IA' },
            calidad: { aprobado: false, motivo: 'Error al verificar con IA' }
        };
    }
}
// ===== REVISAR IMAGEN DESTACADA CON IA =====
app.post('/api/revisar-imagen-destacada', verificarTokenFirebase, upload.single('imagen'), async (req, res) => {
    console.log('>>> 🔥 LLEGÓ PETICIÓN A /api/revisar-imagen-destacada');
    console.log('>>> 🔥 BODY:', req.body);
    console.log('>>> 🔥 FILE:', req.file);
    
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No se subió imagen' });
        }

        const { vendedor_id, nombre, descripcion, precio, categoria, subcategoria, direccion } = req.body;
        
        if (!vendedor_id) {
            return res.status(400).json({ error: 'vendedor_id es requerido' });
        }

        // 🔥 Verificar que el vendedor_id del body coincida con el del token
        if (vendedor_id !== req.usuarioAutenticado) {
            if (req.file) { try { fs.unlinkSync(req.file.path); } catch (_) {} }
            console.log('>>> ❌ UID no coincide en POST /api/revisar-imagen-destacada');
            return res.status(403).json({
                error: 'No autorizado para publicar a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const imagenPath = `/uploads/${req.file.filename}`;
        console.log('>>> Imagen guardada:', imagenPath);

        // ============================================================
        // 1. CREAR EL PRODUCTO (SIEMPRE NUEVO)
        // ============================================================
        console.log('>>> 🔥 VENDEDOR_ID RECIBIDO:', vendedor_id);
        console.log('>>> Creando nuevo producto...');
        
        // Obtener nombre del vendedor
        let vendedor_nombre = '';
        const userResult = await pool.query('SELECT nombre FROM usuarios WHERE uid = $1', [vendedor_id]);
        if (userResult.rows.length > 0) {
            vendedor_nombre = userResult.rows[0].nombre;
            console.log('>>> VENDEDOR_NOMBRE:', vendedor_nombre);
        }

        // Obtener provincia Y cantón desde coordenadas
        let provincia = '';
        let canton = '';
        if (direccion && direccion.includes(',')) {
            try {
                const latLng = direccion.split(',');
                const lat = latLng[0].replace('Lat: ', '').trim();
                const lng = latLng[1].replace('Lng: ', '').trim();
                const geoResponse = await axios.get(
                    `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json&addressdetails=1&zoom=10`,
                    { headers: { 'User-Agent': 'MiMarketplaceCR/1.0' } }
                );
                const address = geoResponse.data.address;
                provincia = address?.state || address?.region || '';
                canton = address?.county || address?.city || address?.town || address?.municipality || '';
                console.log('>>> 📍 Provincia:', provincia, '| Cantón:', canton);
            } catch (e) {
                console.log('Error al obtener provincia:', e.message);
            }
        }

        const result = await pool.query(
            `INSERT INTO productos_app 
            (nombre, descripcion, precio, categoria, subcategoria, vendedor_id, direccion, 
             imagen_url, vendedor_nombre, provincia, canton, imagen_destacada, imagenes_reales, 
             estado_moderacion, estado_ia_destacada, destacada_publicada, fecha_expiracion) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, 'pendiente', 'pendiente', false, NOW() + INTERVAL '30 days') 
            RETURNING id`,
            [
                nombre || 'Producto en revisión',
                descripcion || '',
                parseFloat(precio) || 0,
                categoria || 'Sin categoría',
                subcategoria || '',
                vendedor_id,
                direccion || '',
                imagenPath,
                vendedor_nombre,
                provincia,
                canton,
                imagenPath,
                '[]'
            ]
        );

        const producto_id = result.rows[0].id;
        console.log('>>> ✅ Producto creado con ID:', producto_id);

        // ============================================================
        // 2. ANALIZAR CON IA EN SEGUNDO PLANO
        // ============================================================
        (async () => {
            try {
                console.log('>>> Iniciando análisis IA para imagen destacada...');
                
                // 🔥 UNIFICAR AMBAS REVISIONES EN UNA SOLA LLAMADA
                const resultadoUnificado = await analizarImagenCompleta(imagenPath);
                console.log('>>> Resultado unificado:', resultadoUnificado);

                const aprobado = resultadoUnificado.moderacion.aprobado && resultadoUnificado.calidad.aprobado;
                const motivo = !resultadoUnificado.moderacion.aprobado 
                    ? resultadoUnificado.moderacion.motivo 
                    : resultadoUnificado.calidad.motivo;

                if (aprobado) {
                    await pool.query(
                        `UPDATE productos_app 
                         SET estado_ia_destacada = 'aprobado',
                             destacada_publicada = true
                         WHERE id = $1`,
                        [producto_id]
                    );
                    console.log('>>> ✅ Imagen destacada APROBADA y PUBLICADA para producto:', producto_id);
                    
                    await pool.query(
                        `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha)
                         SELECT vendedor_id, $1, '✅ Tu imagen destacada ha sido aprobada y ya es visible.', 'exito', NOW()
                         FROM productos_app WHERE id = $1`,
                        [producto_id]
                    );
                } else {
    let motivo = '';
    if (!resultadoUnificado.moderacion.aprobado) {
        motivo = resultadoUnificado.moderacion.motivo || 'Producto no permitido';
    } else if (!resultadoUnificado.calidad.aprobado) {
        motivo = resultadoUnificado.calidad.motivo || 'Calidad de imagen insuficiente';
    }

                    await pool.query(
                        `UPDATE productos_app 
                         SET estado_ia_destacada = 'rechazado',
                             motivo_rechazo_destacada = $1
                         WHERE id = $2`,
                        [motivo, producto_id]
                    );
                    console.log('>>> ❌ Imagen destacada RECHAZADA para producto:', producto_id, 'Motivo:', motivo);
                    
                    await pool.query(
                        `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha)
                         SELECT vendedor_id, $1, '❌ Tu imagen destacada fue rechazada: ${motivo}', 'error', NOW()
                         FROM productos_app WHERE id = $1`,
                        [producto_id]
                    );
                }
            } catch (error) {
                console.error('Error en análisis IA destacada:', error);
            }
        })();

        // ============================================================
        // 3. RESPONDER CON EL ID DEL PRODUCTO
        // ============================================================
        res.json({
            success: true,
            mensaje: 'Imagen enviada a revisión. Recibirás una notificación cuando sea aprobada.',
            estado: 'pendiente',
            producto_id: producto_id
        });

    } catch (error) {
        console.error('Error al revisar imagen destacada:', error);
        res.status(500).json({ error: error.message });
    }
});
// ===== OBTENER ANÁLISIS DE UNA CONVERSACIÓN =====
app.get('/api/conversaciones/:conversacion_id/analisis', async (req, res) => {
    try {
        const { conversacion_id } = req.params;
        const result = await pool.query(
            `SELECT analisis_ia, estado_ia, quiere_encuentro, acuerdo_cerrado, quiere_cerrar_trato, fecha_analisis 
             FROM conversaciones_app 
             WHERE id = $1`,
            [conversacion_id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }

        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error al obtener análisis:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== ANALIZAR CONVERSACIÓN EN SEGUNDO PLANO =====
async function analizarConversacionEnSegundoPlano(conversacionId, usuarioId) {
    try {
        console.log('>>> 🚨🚨🚨 DEEPSEEK LLAMADO DESDE analizarConversacionEnSegundoPlano - conv:', conversacionId);
        console.log('>>> 🚨 QUIÉN LLAMA: POST /api/mensajes');
        console.trace('>>> 🚨 STACK TRACE:');

        // 🔥 1. OBTENER LOS ÚLTIMOS 20 MENSAJES
        // 🔥 FILTRAR: mensajes del sistema, mensajes internos (|| ... ||) y los nuestros
        const mensajesResult = await pool.query(
            `SELECT m.usuario_id, m.texto, m.fecha, u.nombre AS remitente
             FROM mensajes_app m
             LEFT JOIN usuarios u ON m.usuario_id = u.uid
             WHERE m.conversacion_id = $1
               AND m.usuario_id != 'SYSTEM'
               AND m.texto IS NOT NULL
               AND m.texto != ''
               AND m.texto NOT LIKE '||%'
             ORDER BY m.fecha DESC
             LIMIT 20`,
            [conversacionId]
        );

        if (mensajesResult.rows.length === 0) {
            console.log('>>> 🤖 No hay mensajes para analizar');
            return;
        }

        // 🔥 2. FORMATEAR LA CONVERSACIÓN
        const mensajes = mensajesResult.rows.reverse();
        const conversacionFormateada = mensajes.map(m => {
            const remitente = m.remitente || 'Usuario';
            const esMio = m.usuario_id === usuarioId;
            const prefijo = esMio ? '[YO]' : `[${remitente}]`;
            return `${prefijo}: ${m.texto}`;
        }).join('\n');

        console.log('>>> 📝 Conversación a analizar (últimos 20 mensajes):');
        console.log(conversacionFormateada);

        // 🔥 3. LLAMAR A DEEPSEEK
        const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;
        const url = 'https://api.deepseek.com/v1/chat/completions';

        const ultimoMensajeTexto = mensajes[mensajes.length - 1]?.texto || '';
        const prompt = `Analiza esta conversación de un marketplace en Costa Rica entre un comprador y un vendedor.

CONVERSACIÓN:
${conversacionFormateada}

ÚLTIMO MENSAJE (el más reciente): "${ultimoMensajeTexto}"

INSTRUCCIONES:
Determina el estado de la conversación según estas señales:

1. ESTAFA o FRAUDE (precios muy bajos, urgencia, pedir dinero fuera de la plataforma, pedir SINPE por adelantado, datos bancarios)
2. MALENTENDIDOS (información confusa, promesas poco claras, contradicciones)
3. INFORMACIÓN OMITIDA (no responde preguntas, evade temas importantes)
4. COMPORTAMIENTO SOSPECHOSO (insiste en algo, presión, amenazas, lenguaje agresivo)
5. CONVERSACIÓN SALUDABLE (diálogo respetuoso, claro, sin señales de alerta)

RESPONDE ÚNICAMENTE CON UN JSON VÁLIDO:
{
  "estado": "good" | "warning" | "danger" | "neutral",
  "analisis": "Explicación breve en español (máximo 150 caracteres) de por qué elegiste ese estado",
  "quiere_encuentro": true/false,
  "acuerdo_cerrado": true/false,
  "quiere_cerrar_trato": true/false
}

CRITERIOS:
- "good": conversación respetuosa, clara, sin señales de riesgo
- "warning": hay señales leves de alerta (evasivas, insistencia, ambigüedad)
- "danger": hay señales claras de fraude, agresión o riesgo
- "neutral": conversación muy corta, sin contexto de marketplace, o solo mensajes afectivos sin información relevante

SOBRE "quiere_encuentro":
- Mirá SOLO el "ÚLTIMO MENSAJE". Si ese mensaje NO pide explícitamente verse en persona ("quiero un encuentro", "nos vemos", "juntémonos", "agendemos"), devolvé false. Los mensajes anteriores NO cuentan para este campo.
- Un mensaje afectivo, sexual, un insulto o un saludo NO es un encuentro. Si dudás, false.

SOBRE "acuerdo_cerrado":
- true: si AMBOS usuarios ya llegaron a un acuerdo concreto sobre el encuentro. Ejemplos: "dale, nos vemos el sábado a las 3", "listo, quedamos en el parque", "perfecto, ahí nos vemos", "confirmado, mañana a las 10 en la entrada". O sea, ya se pusieron de acuerdo en fecha, hora o lugar, y ambos aceptaron.
- false: si todavía están negociando, preguntando, o no hay un acuerdo claro de ambas partes.

SOBRE "quiere_cerrar_trato":
Pon "quiere_cerrar_trato": true si AL MENOS UNO de estos casos se cumple:
1. AMBOS usuarios expresaron que quieren cerrar la conversación (despedida, "hasta pronto", "nos vemos", "en eso quedamos", "me retiro", "listo", "quedamos así", "perfecto", "de acuerdo", etc.)
2. UN usuario propuso cerrar Y el OTRO respondió con una confirmación clara ("sí", "dale", "ok", "listo", "así quedamos", "en eso quedamos", "perfecto", "de acuerdo", etc.)

Si solo UN usuario expresó el cierre y el otro todavía no respondió nada, pon "quiere_cerrar_trato": false.

Ejemplos:
- "[A]: listo, nos vemos" → false (solo uno expresó, el otro no respondió nada)
- "[A]: listo, nos vemos / [B]: sí, nos vemos" → true (los dos expresaron)
- "[A]: en eso quedamos / [B]: en eso quedamos" → true (los dos expresaron)
- "[A]: bueno en eso quedamos entonces / [B]: en eso quedamos" → true
- "[A]: en eso quedamos, hasta entonces" → false (solo uno)
- "[A]: en eso quedamos, hasta entonces / [B]: sí, así quedamos" → true (los dos)

Sé generoso con este campo. Si la conversación suena a que ya se pusieron de acuerdo en cerrar, pon true. Es mejor activar el modal que el usuario ignore, que no activarlo y que el usuario tenga que hacerlo a mano.

NO cuentes mensajes repetidos del MISMO usuario. Tienen que ser DOS usuarios DISTINTOS.

En el campo "analisis", SIEMPRE da una recomendación útil, incluso si es "neutral".`;

        const response = await axios.post(url, {
            model: 'deepseek-chat',
            messages: [
                { 
                    role: 'system', 
                    content: 'Eres un asistente experto en detectar fraudes en conversaciones de marketplace. Analizas el contexto completo de la conversación. Responde SOLO con JSON. IMPORTANTE: "quiere_encuentro" solo es true si el ÚLTIMO mensaje de la conversación pide explícitamente verse en persona. Mensajes afectivos, sexuales, insultos o saludos NO cuentan como encuentro. Si dudás, false.' 
                },
                { role: 'user', content: prompt }
            ],
            temperature: 0,
            max_tokens: 200,
        }, {
            headers: {
                'Authorization': `Bearer ${DEEPSEEK_API_KEY}`,
                'Content-Type': 'application/json'
            },
            timeout: 15000
        });

        const usage = response.data.usage;
        console.log('>>> 📊 TOKENS GASTADOS:');
        console.log('>>>   - Prompt tokens: ' + (usage?.prompt_tokens || 'N/A'));
        console.log('>>>   - Completion tokens: ' + (usage?.completion_tokens || 'N/A'));
        console.log('>>>   - Total tokens: ' + (usage?.total_tokens || 'N/A'));

        const text = response.data.choices?.[0]?.message?.content || '';
        console.log('>>> 🤖 Respuesta de DeepSeek:', text);

        const jsonMatch = text.match(/\{[\s\S]*\}/);
        
        if (jsonMatch) {
            try {
                const resultado = JSON.parse(jsonMatch[0]);
                const estado = resultado.estado || 'neutral';
                const analisis = resultado.analisis || 'Análisis completado';
                const quiereEncuentro = resultado.quiere_encuentro === true;

                // 🔥 4. GUARDAR EN LA BD (incluye quiere_encuentro y acuerdo_cerrado)
                const acuerdoCerrado = resultado.acuerdo_cerrado === true;
                // 🔥 Respaldo por palabras: dos usuarios distintos se despidieron
                const normalizar = t => (t || '').toLowerCase()
                    .normalize('NFD').replace(/[\u0300-\u036f]/g, '');
                const reDespedida = /(nos vemos|hasta luego|hasta pronto|hasta entonces|hasta manana|chao|chau|adios|bye|cuidese|cuidate|nos hablamos|me retiro|quedamos asi|en eso quedamos|pura vida|buenas noches|que le vaya bien|que te vaya bien|gracias por todo)/;
                const usuariosDespidieron = new Set(
                    mensajes.slice(-4)
                        .filter(m => reDespedida.test(normalizar(m.texto)))
                        .map(m => m.usuario_id)
                );
                const porRegex = usuariosDespidieron.size >= 2;

                // 🔥 Pegajoso: si ya estaba activo, no se apaga hasta cancelar o seguir
                const previo = await pool.query(
                    'SELECT quiere_cerrar_trato FROM conversaciones_app WHERE id = $1',
                    [conversacionId]
                );
                const yaEstabaActivo = previo.rows[0]?.quiere_cerrar_trato === true;
                const quiereCerrarTrato =
                    yaEstabaActivo || resultado.quiere_cerrar_trato === true || porRegex;

                await pool.query(
                    `UPDATE conversaciones_app 
                     SET analisis_ia = $1, 
                         estado_ia = $2, 
                         quiere_encuentro = $3,
                         acuerdo_cerrado = $4,
                         quiere_cerrar_trato = $5,
                         fecha_analisis = NOW()
                     WHERE id = $6`,
                    [analisis, estado, quiereEncuentro, acuerdoCerrado, quiereCerrarTrato, conversacionId]
                );

                console.log('>>> 🤝 ¿Acuerdo cerrado?:', acuerdoCerrado);

                // 🔥 Si la IA detecta cierre, el "seguir conversando" ya no aplica.
                if (quiereCerrarTrato && !yaEstabaActivo) {
                    const borrados = await pool.query(
                        `DELETE FROM mensajes_app 
                         WHERE conversacion_id = $1 
                           AND texto LIKE '||SEGUIR_CONVERSANDO||%'`,
                        [conversacionId]
                    );
                    if (borrados.rowCount > 0) {
                        console.log(`>>> 🧹 "Seguir conversando" borrado por IA: ${borrados.rowCount} registros`);
                    }
                }

                console.log('>>> ✅ Análisis guardado en conversación', conversacionId);
                console.log('>>> 🤝 ¿Quiere encuentro?:', quiereEncuentro);
            } catch (e) {
                console.error('>>> ❌ Error al parsear JSON:', e.message);
            }
        }
    } catch (error) {
        console.error('>>> ❌ Error en analizarConversacionEnSegundoPlano:', error.message);
    }
}

// ===== ANALIZAR CHAT CON IA (DEEPSEEK) - VERSIÓN MEJORADA =====
app.post('/api/analizar-chat', async (req, res) => {
    try {
        console.log('>>> 🚨🚨🚨 DEEPSEEK LLAMADO DESDE POST /api/analizar-chat');
        console.log('>>> 🚨 Body:', req.body);
        const { conversacion_id, usuario_id } = req.body;

        if (!conversacion_id) {
            return res.json({ 
                estado: 'neutral', 
                analisis: 'Conversación no especificada' 
            });
        }

        // 🔥 1. OBTENER LOS ÚLTIMOS 20 MENSAJES
        // 🔥 FILTRAR: mensajes del sistema, mensajes internos (|| ... ||)
        const mensajesResult = await pool.query(
            `SELECT m.usuario_id, m.texto, m.fecha, u.nombre AS remitente
             FROM mensajes_app m
             LEFT JOIN usuarios u ON m.usuario_id = u.uid
             WHERE m.conversacion_id = $1
               AND m.usuario_id != 'SYSTEM'
               AND m.texto IS NOT NULL
               AND m.texto != ''
               AND m.texto NOT LIKE '||%'
             ORDER BY m.fecha DESC
             LIMIT 20`,
            [conversacion_id]
        );

        if (mensajesResult.rows.length === 0) {
            return res.json({ 
                estado: 'neutral', 
                analisis: 'No hay mensajes suficientes para analizar' 
            });
        }

        // 🔥 2. CONSTRUIR LA CONVERSACIÓN FORMATEADA
        const mensajes = mensajesResult.rows.reverse();

        const conversacionFormateada = mensajes.map(m => {
            const remitente = m.remitente || 'Usuario';
            const esMio = m.usuario_id === usuario_id;
            const prefijo = esMio ? '[YO]' : `[${remitente}]`;
            return `${prefijo}: ${m.texto}`;
        }).join('\n');

        console.log('>>> 📝 Conversación a analizar (últimos 20 mensajes):');
        console.log(conversacionFormateada);

        const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;
        const url = 'https://api.deepseek.com/v1/chat/completions';

        const prompt = `Analiza esta conversación de un marketplace en Costa Rica entre un comprador y un vendedor.

CONVERSACIÓN:
${conversacionFormateada}

INSTRUCCIONES:
Determina el estado de la conversación según estas señales:

1. ESTAFA o FRAUDE (precios muy bajos, urgencia, pedir dinero fuera de la plataforma, pedir SINPE por adelantado, datos bancarios)
2. MALENTENDIDOS (información confusa, promesas poco claras, contradicciones)
3. INFORMACIÓN OMITIDA (no responde preguntas, evade temas importantes)
4. COMPORTAMIENTO SOSPECHOSO (insiste en algo, presión, amenazas, lenguaje agresivo)
5. CONVERSACIÓN SALUDABLE (diálogo respetuoso, claro, sin señales de alerta)

RESPONDE ÚNICAMENTE CON UN JSON VÁLIDO:
{
  "estado": "good" | "warning" | "danger" | "neutral",
  "analisis": "Explicación breve en español (máximo 150 caracteres) de por qué elegiste ese estado"
}

CRITERIOS:
- "good": conversación respetuosa, clara, sin señales de riesgo
- "warning": hay señales leves de alerta (evasivas, insistencia, ambigüedad)
- "danger": hay señales claras de fraude, agresión o riesgo
- "neutral": conversación muy corta o sin suficiente información`;

        const response = await axios.post(url, {
            model: 'deepseek-chat',
            messages: [
                { 
                    role: 'system', 
                    content: 'Eres un asistente experto en detectar fraudes en conversaciones de marketplace. Analizas el contexto completo de la conversación, no solo un mensaje aislado. Responde SOLO con JSON.' 
                },
                { role: 'user', content: prompt }
            ],
            temperature: 0.1,
            max_tokens: 200,
        }, {
            headers: {
                'Authorization': `Bearer ${DEEPSEEK_API_KEY}`,
                'Content-Type': 'application/json'
            },
            timeout: 15000
        });

        const usage = response.data.usage;
        console.log('>>> 📊 TOKENS GASTADOS:');
        console.log('>>>   - Prompt tokens: ' + (usage?.prompt_tokens || 'N/A'));
        console.log('>>>   - Completion tokens: ' + (usage?.completion_tokens || 'N/A'));
        console.log('>>>   - Total tokens: ' + (usage?.total_tokens || 'N/A'));

        const text = response.data.choices?.[0]?.message?.content || '';
        console.log('>>> 🤖 Respuesta de DeepSeek:', text);

        const jsonMatch = text.match(/\{[\s\S]*\}/);
        
        if (jsonMatch) {
            try {
                const resultado = JSON.parse(jsonMatch[0]);
                return res.json({
                    estado: resultado.estado || 'neutral',
                    analisis: resultado.analisis || 'Análisis completado'
                });
            } catch (e) {
                console.error('>>> ❌ Error al parsear JSON:', e.message);
                return res.json({ estado: 'neutral', analisis: 'Error al analizar' });
            }
        }

        res.json({ estado: 'neutral', analisis: 'No se pudo analizar' });

    } catch (error) {
        console.error('Error en analizar-chat:', error.message);
        res.json({ estado: 'neutral', analisis: 'Error al analizar' });
    }
});
// ============================================================
// 🔥 OBTENER PRODUCTOS CADUCADOS DE UN USUARIO
// ============================================================
app.get('/api/productos/caducados/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;
        const result = await pool.query(
            'SELECT * FROM productos_app WHERE vendedor_id = $1 AND estado = $2 ORDER BY fecha_expiracion DESC',
            [usuario_id, 'caducado']
        );
        res.json(result.rows);
    } catch (error) {
        console.error('Error al obtener productos caducados:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔥 RENOVAR PRODUCTO CADUCADO (CON ANUNCIO)
// ============================================================
app.post('/api/productos/renovar/:id', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;
        const { usuario_id } = req.body;

        console.log('>>> 🔄 Renovar producto. Usuario autenticado:', req.usuarioAutenticado);
        console.log('>>> 🔄 Usuario del body:', usuario_id);

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en renovar producto');
            return res.status(403).json({
                error: 'No autorizado para renovar este producto',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const checkQuery = 'SELECT * FROM productos_app WHERE id = $1 AND vendedor_id = $2';
        const checkResult = await pool.query(checkQuery, [id, usuario_id]);

        if (checkResult.rows.length === 0) {
            return res.status(404).json({ error: 'Producto no encontrado o no te pertenece' });
        }

        const producto = checkResult.rows[0];
        const nombre = producto.nombre || 'Producto';

        const updateQuery = `
            UPDATE productos_app 
            SET estado = 'activo', 
                fecha_expiracion = NOW() + INTERVAL '30 days'
            WHERE id = $1 
            RETURNING *
        `;
        const result = await pool.query(updateQuery, [id]);

        await pool.query(
            'DELETE FROM alertas WHERE producto_id = $1 AND tipo = $2',
            [id, 'caducado']
        );

        // 🔥 ELIMINAR REGISTRO DE AVISO DADO PARA QUE EL CRON PUEDA CREAR NUEVA ALERTA
        await pool.query(
            'DELETE FROM alertas_caducidad WHERE producto_id = $1 AND usuario_id = $2',
            [id, usuario_id]
        );

        await pool.query(
            `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
             VALUES ($1, $2, $3, $4, NOW())`,
            [
                usuario_id,
                id,
                `🔄 Tu producto "${nombre}" ha sido renovado por 30 días más.`,
                'exito'
            ]
        );

        console.log(`>>> ✅ Producto ${id} renovado por 30 días`);

        res.json({
            mensaje: '✅ Producto renovado por 30 días más',
            producto: result.rows[0]
        });

    } catch (error) {
        console.error('Error al renovar producto:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔥 GUARDAR FCM TOKEN DE UN USUARIO
// ============================================================
app.post('/api/usuarios/fcm-token', verificarTokenFirebase, async (req, res) => {
    try {
        const { uid, fcm_token } = req.body;

        if (!uid || !fcm_token) {
            return res.status(400).json({ error: 'uid y fcm_token requeridos' });
        }

        // 🔥 Verificar que el uid del body coincida con el del token
        if (uid !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/usuarios/fcm-token');
            return res.status(403).json({
                error: 'No autorizado para modificar el FCM token de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        await pool.query(
            'UPDATE usuarios SET fcm_token = $1 WHERE uid = $2',
            [fcm_token, uid]
        );

        console.log(`>>> 📱 FCM token guardado para usuario ${uid}`);
        res.json({ success: true });
    } catch (error) {
        console.error('Error al guardar FCM token:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔥 OBTENER DATOS DE UN USUARIO
// ============================================================
// 🔥 CONSULTAR SI UN USUARIO ESTÁ EN LÍNEA
app.get('/api/usuarios/:uid/en-linea', async (req, res) => {
    try {
        const { uid } = req.params;
        const enLinea = usuariosEnLinea.has(uid) &&
            (Date.now() - usuariosEnLinea.get(uid) < USUARIO_TIMEOUT_MS);
        res.json({ en_linea: enLinea });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// 🔥 CONSULTAR ÚLTIMA CONEXIÓN DE UN USUARIO
app.get('/api/usuarios/:uid/ultima-conexion', async (req, res) => {
    try {
        const { uid } = req.params;
        const result = await pool.query(
            'SELECT ultima_conexion FROM usuarios WHERE uid = $1',
            [uid]
        );
        if (result.rows.length === 0) {
            return res.json({ ultima_conexion: null });
        }
        res.json({
            ultima_conexion: result.rows[0].ultima_conexion,
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
app.get('/api/usuarios/:uid', verificarTokenFirebase, async (req, res) => {
    try {
        const { uid } = req.params;

        // 🔥 Verificar que el uid de la URL coincida con el del token
        if (uid !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en GET /api/usuarios/:uid');
            return res.status(403).json({
                error: 'No autorizado para ver datos de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        const result = await pool.query(
            'SELECT uid, email, nombre, telefono, acepta_recoleccion FROM usuarios WHERE uid = $1',
            [uid]
        );
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔥 ACTUALIZAR DATOS DE UN USUARIO
// ============================================================
app.put('/api/usuarios/:uid', verificarTokenFirebase, async (req, res) => {
    try {
         const { uid } = req.params;
        const { nombre, telefono, acepta_recoleccion } = req.body;
        
        console.log('>>> 👤 Actualizar usuario. UID de la URL:', uid);
        console.log('>>> 👤 Usuario autenticado (token):', req.usuarioAutenticado);

        // 🔥 Verificar que el uid de la URL coincida con el del token
        if (uid !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en actualizar usuario');
            return res.status(403).json({
                error: 'No autorizado para modificar este perfil',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 CONSTRUIR QUERY DINÁMICA
        let query = 'UPDATE usuarios SET ';
        const params = [];
        let paramIndex = 1;
        
        if (nombre !== undefined) {
            query += `nombre = $${paramIndex}, `;
            params.push(nombre);
            paramIndex++;
        }
        
        if (telefono !== undefined) {
            query += `telefono = $${paramIndex}, `;
            params.push(telefono);
            paramIndex++;
        }
        
        if (acepta_recoleccion !== undefined) {
            query += `acepta_recoleccion = $${paramIndex}, `;
            params.push(acepta_recoleccion);
            paramIndex++;
        }
        
        // Eliminar la última coma y espacio
        query = query.slice(0, -2);
        query += ` WHERE uid = $${paramIndex} RETURNING *`;
        params.push(uid);
        
        const result = await pool.query(query, params);
        
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        
        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error al actualizar usuario:', error);
        res.status(500).json({ error: error.message });
    }
});
// ============================================================
// 🔥 GUARDAR CALIFICACIÓN CON COMENTARIO
// ============================================================
app.post('/api/calificaciones', verificarTokenFirebase, async (req, res) => {
    try {
        const { calificado_id, calificador_id, producto_id, puntuacion, comentario } = req.body;
        
        console.log('>>> 🔥 ====== GUARDANDO CALIFICACIÓN ======');
        console.log('>>> calificado_id (vendedor):', calificado_id);
        console.log('>>> calificador_id (comprador):', calificador_id);
        console.log('>>> 🔐 Usuario autenticado (token):', req.usuarioAutenticado);
        console.log('>>> producto_id:', producto_id);
        console.log('>>> puntuacion:', puntuacion);
        console.log('>>> comentario:', comentario);

        // 🔥 Verificar que el calificador_id del body coincida con el del token
        if (calificador_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide, rechazando calificación');
            return res.status(403).json({
                error: 'No autorizado para calificar con este usuario_id',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 BUSCAR LA CONVERSACIÓN MÁS RECIENTE
        const convResult = await pool.query(
            `SELECT c.id FROM conversaciones_app c
             WHERE c.producto_id = $1 
               AND ((c.usuario1_id = $2 AND c.usuario2_id = $3)
                    OR (c.usuario1_id = $3 AND c.usuario2_id = $2))
             ORDER BY c.id DESC
             LIMIT 1`,
            [producto_id, calificador_id, calificado_id]
        );

        if (convResult.rows.length > 0) {
            const conversacionId = convResult.rows[0].id;
            console.log('>>> Conversación encontrada:', conversacionId);

            // 🔥 BORRAR EL MENSAJE DE SOLICITUD DE CALIFICACIÓN
            await pool.query(
                `DELETE FROM mensajes_app 
                 WHERE conversacion_id = $1 
                   AND texto = '||EL_COMPRADOR_YA_PUEDE_CALIFICARTE||'`,
                [conversacionId]
            );
            console.log('>>> 🗑️ Mensaje de solicitud de calificación borrado');

            // 🔥 EVITAR MENSAJES DUPLICADOS EN LOS ÚLTIMOS 5 SEGUNDOS
            try {
                const yaExiste = await pool.query(
                    `SELECT id FROM mensajes_app 
                     WHERE conversacion_id = $1 
                       AND usuario_id = 'SYSTEM'
                       AND texto LIKE '✅ Has calificado%'
                       AND fecha > NOW() - INTERVAL '5 seconds'`,
                    [conversacionId]
                );

                if (yaExiste.rows.length === 0) {
                    await pool.query(
                        `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
                         VALUES ($1, $2, $3, $4, NOW())`,
                        [
                            conversacionId,
                            'SYSTEM',
                            `||CALIFICACION_REALIZADA||${calificador_id}`,
                            ''
                        ]
                    );
                    console.log('>>> ✅ Mensaje de confirmación insertado');
                } else {
                    console.log('>>> ⏭️ Mensaje ya insertado hace <5s, omitiendo');
                }
            } catch (msgError) {
                console.log('>>> ⚠️ Error al insertar mensaje de confirmación (no crítico):', msgError.message);
            }
        }

        // 🔥 LA TABLA USA "usuario_id" (el que recibe) y "calificador_id" (el que califica)
        const checkResult = await pool.query(
            `SELECT * FROM calificaciones 
             WHERE usuario_id = $1 AND calificador_id = $2 AND producto_id = $3`,
            [calificado_id, calificador_id, producto_id]
        );

        if (checkResult.rows.length > 0) {
            const result = await pool.query(
                `UPDATE calificaciones 
                 SET puntuacion = $1, comentario = $2, fecha = NOW()
                 WHERE usuario_id = $3 AND calificador_id = $4 AND producto_id = $5
                 RETURNING *`,
                [puntuacion, comentario, calificado_id, calificador_id, producto_id]
            );
            res.json(result.rows[0]);
        } else {
            const result = await pool.query(
                `INSERT INTO calificaciones (usuario_id, calificador_id, producto_id, puntuacion, comentario, fecha)
                 VALUES ($1, $2, $3, $4, $5, NOW())
                 RETURNING *`,
                [calificado_id, calificador_id, producto_id, puntuacion, comentario]
            );
            res.status(201).json(result.rows[0]);
        }
    } catch (error) {
        console.error('>>> ❌ Error al guardar calificación:', error);
        res.status(500).json({ error: error.message });
    }
});
// ============================================================
// 🔥 VERIFICAR SI HAY CALIFICACIÓN PENDIENTE
// ============================================================
// ============================================================
// 🔥 VERIFICAR SI HAY CALIFICACIÓN PENDIENTE (SOLO PARA COMPRADOR)
// ============================================================
app.get('/api/conversaciones/:conversacionId/calificacion-pendiente', async (req, res) => {
    try {
        const { conversacionId } = req.params;
        const usuarioId = req.query.usuario_id;
        
        console.log('>>> 🔥 ====== VERIFICANDO CALIFICACIÓN ======');
        console.log('>>> Conversación ID:', conversacionId);
        console.log('>>> Usuario que pregunta (usuarioId):', usuarioId);
        
        // 🔥 CONSULTA CORREGIDA: OBTENER vendedor_id DESDE productos_app
        const convResult = await pool.query(
            `SELECT c.usuario1_id, c.usuario2_id, c.producto_id, p.vendedor_id
             FROM conversaciones_app c
             LEFT JOIN productos_app p ON c.producto_id = p.id
             WHERE c.id = $1`,
            [conversacionId]
        );

        if (convResult.rows.length === 0) {
            console.log('>>> ❌ Conversación NO encontrada');
            return res.json({ pendiente: false });
        }

        const conv = convResult.rows[0];
        console.log('>>> 📊 DATOS DE LA CONVERSACIÓN:');
        console.log('>>>   usuario1_id:', conv.usuario1_id);
        console.log('>>>   usuario2_id:', conv.usuario2_id);
        console.log('>>>   vendedor_id:', conv.vendedor_id);
        console.log('>>>   producto_id:', conv.producto_id);

        const vendedorId = conv.vendedor_id;
        const productoId = conv.producto_id;

               // 🔥 SI EL QUE PREGUNTA ES EL VENDEDOR → NO PUEDE CALIFICAR
        if (usuarioId === vendedorId) {
            console.log('>>> ❌ EL VENDEDOR NO PUEDE CALIFICAR - RETORNANDO pendiente: false');
            return res.json({ 
                pendiente: false,
                vendedor_id: vendedorId,
                producto_id: productoId,
            });
        }

        // 🔥 VERIFICAR SI EL COMPRADOR YA CALIFICÓ
        const califResult = await pool.query(
            `SELECT * FROM calificaciones 
             WHERE usuario_id = $1 AND producto_id = $2`,
            [vendedorId, productoId]
        );

        const pendiente = califResult.rows.length === 0;
        console.log('>>> ✅ RESULTADO FINAL - pendiente:', pendiente);
        console.log('>>> 🔥 ANTES DE RESPONDER - vendedorId:', vendedorId);
        console.log('>>> 🔥 ANTES DE RESPONDER - productoId:', productoId);
        console.log('>>> 🔥 ANTES DE RESPONDER - pendiente:', pendiente);
        res.json({ 
            pendiente: pendiente,
            vendedor_id: vendedorId,
            producto_id: productoId,
        });
    } catch (error) {
        console.error('>>> ❌ ERROR EN EL ENDPOINT:', error);
        res.status(500).json({ error: error.message });
    }
});
// ============================================================
// 🔥 SOPORTE - ENVIAR MENSAJE
// ============================================================
app.post('/api/soporte/enviar', verificarTokenFirebase, async (req, res) => {
    try {
        const { usuario_id, asunto, mensaje } = req.body;

        if (!usuario_id || !mensaje || mensaje.trim().isEmpty) {
            return res.status(400).json({ error: 'usuario_id y mensaje obligatorios' });
        }

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/soporte/enviar');
            return res.status(403).json({
                error: 'No autorizado para enviar soporte a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // Obtener datos del usuario
        const userResult = await pool.query(
            `SELECT nombre, email FROM usuarios WHERE uid = $1`,
            [usuario_id]
        );

        if (userResult.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        const user = userResult.rows[0];

        // Insertar en la tabla de soporte
        const result = await pool.query(
            `INSERT INTO mensajes_soporte 
             (usuario_id, usuario_nombre, usuario_email, asunto, mensaje, estado, fecha)
             VALUES ($1, $2, $3, $4, $5, 'nuevo', NOW())
             RETURNING *`,
            [
                usuario_id,
                user.nombre || 'Usuario',
                user.email || '',
                asunto || 'Sin asunto',
                mensaje.trim()
            ]
        );

        console.log(`>>> 📬 Mensaje de soporte recibido de ${user.nombre} (${usuario_id})`);

        res.status(201).json({
            success: true,
            mensaje: 'Mensaje enviado. Te responderemos pronto.',
            ticket: result.rows[0]
        });
    } catch (error) {
        console.error('Error al guardar soporte:', error);
        res.status(500).json({ error: error.message });
    }
});
// ============================================================
// 🛡️ ESCUDO DE SEGURIDAD
// ============================================================

// ACTIVAR ESCUDO (mutuo y permanente)
app.post('/api/escudo/activar', verificarTokenFirebase, async (req, res) => {
    try {
        const { conversacion_id, usuario_id, activo } = req.body;
        if (!conversacion_id || !usuario_id) {
            return res.status(400).json({ error: 'conversacion_id y usuario_id requeridos' });
        }

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en escudo/activar');
            return res.status(403).json({
                error: 'No autorizado para activar el escudo con este usuario_id',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 El escudo solo se puede ACTIVAR, no desactivar.
        if (activo !== true) {
            return res.status(400).json({ 
                error: 'El Escudo de Seguridad no se puede desactivar una vez activado.',
                codigo: 'ESCUDO_NO_DESACTIVABLE'
            });
        }

        // 🔥 Obtener los dos usuarios de la conversación
        const convResult = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [conversacion_id]
        );

        if (convResult.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }

        const conv = convResult.rows[0];
        const usuarios = [conv.usuario1_id, conv.usuario2_id];

        // 🔥 Activar el escudo para LOS DOS usuarios.
        // 🔥 Quien lo activa queda con acepto = true automáticamente.
        // 🔥 El otro queda con acepto = false y debe aceptar o rechazar.
        const results = [];
        for (const uid of usuarios) {
            const soyYo = uid === usuario_id;
            const r = await pool.query(
                `INSERT INTO escudos_conversacion 
                 (conversacion_id, usuario_id, activo, video_visto, 
                  usuario_activo, acepto, rechazo, fecha_respuesta,
                  fecha_activacion, fecha_expiracion)
                 VALUES ($1, $2, true, true, $3, $4, false, $5, NOW(), NOW() + INTERVAL '30 days')
                 ON CONFLICT (conversacion_id, usuario_id) 
                 DO UPDATE SET 
                    activo = true,
                    video_visto = true,
                    usuario_activo = $3,
                    acepto = CASE WHEN escudos_conversacion.acepto = true THEN true ELSE $4 END,
                    rechazo = false,
                    fecha_respuesta = COALESCE(escudos_conversacion.fecha_respuesta, $5),
                    fecha_activacion = NOW(),
                    fecha_expiracion = NOW() + INTERVAL '30 days'
                 RETURNING *`,
                [conversacion_id, uid, usuario_id, soyYo, soyYo ? new Date() : null]
            );
            results.push(r.rows[0]);
        }

        console.log(`>>> 🛡️ Escudo activado en conversación ${conversacion_id} por ${usuario_id}`);

        // 🔥 EMITIR POR WEBSOCKET
        global.broadcast(conversacion_id, {
            tipo: 'estado_cambio',
            estado: 'escudo_activado',
        });

        res.json({ success: true, escudos: results, activado_por: usuario_id });
    } catch (error) {
        console.error('Error al activar escudo:', error);
        res.status(500).json({ error: error.message });
    }
});

// OBTENER ESTADO DEL ESCUDO
app.get('/api/escudo/estado/:conversacion_id/:usuario_id', verificarTokenFirebase, async (req, res) => {
    try {
        const { conversacion_id, usuario_id } = req.params;

        // 🔥 Verificar que el uid de la URL coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en escudo/estado');
            return res.status(403).json({
                error: 'No autorizado para ver el estado del escudo de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 Obtener los dos usuarios de la conversación
        const convResult = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [conversacion_id]
        );

        if (convResult.rows.length === 0) {
            return res.json({ escudo_activo: false, video_visto: false });
        }

        // 🔥 Verificar que el usuario autenticado sea PARTE de la conversación
        const convData = convResult.rows[0];
        if (convData.usuario1_id !== req.usuarioAutenticado && convData.usuario2_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de ver escudo ajeno. User:', req.usuarioAutenticado, '| Conv:', conversacion_id);
            return res.status(403).json({
                error: 'No autorizado para ver el escudo de esta conversación',
                codigo: 'NO_ES_PARTE_DE_LA_CONVERSACION'
            });
        }

        const conv = convResult.rows[0];
        const usuarios = [conv.usuario1_id, conv.usuario2_id];

        // 🔥 Obtener el registro de cada usuario
        const result = await pool.query(
            `SELECT * FROM escudos_conversacion 
             WHERE conversacion_id = $1 AND usuario_id = ANY($2)`,
            [conversacion_id, usuarios]
        );

        if (result.rows.length === 0) {
            return res.json({ 
                escudo_activo: false, 
                video_visto: false,
                yo_acepte: false,
                otro_acepte: false,
                otro_rechazo: false,
                escudo_confirmado: false,
                activado_por: null,
            });
        }

        // 🔥 Verificar si está expirado
        const activos = result.rows.filter(e => 
            e.activo === true && (!e.fecha_expiracion || new Date(e.fecha_expiracion) >= new Date())
        );

        const escudoActivo = activos.length > 0;

        // 🔥 Separar el registro del usuario que pregunta y del otro
        const miRegistro = result.rows.find(r => r.usuario_id === usuario_id);
        const otroRegistro = result.rows.find(r => r.usuario_id !== usuario_id);

        // 🔥 Quién activó
        const activado_por = miRegistro?.usuario_activo || otroRegistro?.usuario_activo || null;

        const yo_acepte = miRegistro?.acepto === true;
        const otro_acepte = otroRegistro?.acepto === true;
        const otro_rechazo = otroRegistro?.rechazo === true;
        const yo_vi_modal = miRegistro?.modal_visto === true;
        const escudo_confirmado = yo_acepte && otro_acepte;

        res.json({
            escudo_activo: escudoActivo,
            video_visto: escudoActivo,
            fecha_activacion: activos[0]?.fecha_activacion || null,
            fecha_expiracion: activos[0]?.fecha_expiracion || null,
            expirado: !escudoActivo,
            activado_por: activado_por,
            yo_acepte: yo_acepte,
            otro_acepte: otro_acepte,
            otro_rechazo: otro_rechazo,
            yo_vi_modal: yo_vi_modal, // 🔥 NUEVO
            escudo_confirmado: escudo_confirmado,
        });
    } catch (error) {
        console.error('Error al obtener estado del escudo:', error);
        res.status(500).json({ error: error.message });
    }
});

// 🔥 ACEPTAR EL ESCUDO (el otro usuario acepta la activación)
app.post('/api/escudo/aceptar', verificarTokenFirebase, async (req, res) => {
    try {
        const { conversacion_id, usuario_id } = req.body;
        if (!conversacion_id || !usuario_id) {
            return res.status(400).json({ error: 'conversacion_id y usuario_id requeridos' });
        }

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en escudo/aceptar');
            return res.status(403).json({
                error: 'No autorizado para aceptar el escudo con este usuario_id',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        await pool.query(
            `UPDATE escudos_conversacion 
             SET acepto = true, rechazo = false, modal_visto = true, fecha_respuesta = NOW()
             WHERE conversacion_id = $1 AND usuario_id = $2`,
            [conversacion_id, usuario_id]
        );

        const r = await pool.query(
            `SELECT acepto FROM escudos_conversacion 
             WHERE conversacion_id = $1`,
            [conversacion_id]
        );
        const ambosAceptaron = r.rows.length >= 2 && r.rows.every(x => x.acepto === true);

        console.log(`>>> 🛡️ Escudo aceptado por ${usuario_id} en conv ${conversacion_id}. Ambos: ${ambosAceptaron}`);
        res.json({ success: true, escudo_confirmado: ambosAceptaron });
    } catch (error) {
        console.error('Error al aceptar escudo:', error);
        res.status(500).json({ error: error.message });
    }
});

// 🔥 MARCAR MODAL COMO VISTO (para no volver a mostrarlo)
app.post('/api/escudo/modal-visto', verificarTokenFirebase, async (req, res) => {
    try {
        const { conversacion_id, usuario_id } = req.body;
        if (!conversacion_id || !usuario_id) {
            return res.status(400).json({ error: 'conversacion_id y usuario_id requeridos' });
        }

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en escudo/modal-visto');
            return res.status(403).json({
                error: 'No autorizado para marcar el modal con este usuario_id',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        await pool.query(
            `UPDATE escudos_conversacion 
             SET modal_visto = true
             WHERE conversacion_id = $1 AND usuario_id = $2`,
            [conversacion_id, usuario_id]
        );

        console.log(`>>> 🛡️ Modal escudo marcado como visto por ${usuario_id} en conv ${conversacion_id}`);
        res.json({ success: true });
    } catch (error) {
        console.error('Error al marcar modal visto:', error);
        res.status(500).json({ error: error.message });
    }
});

// 🔥 RECHAZAR EL ESCUDO (cierra el chat para ambos)
app.post('/api/escudo/rechazar', verificarTokenFirebase, async (req, res) => {
    try {
        const { conversacion_id, usuario_id } = req.body;
        if (!conversacion_id || !usuario_id) {
            return res.status(400).json({ error: 'conversacion_id y usuario_id requeridos' });
        }

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en escudo/rechazar (intento de cerrar chat ajeno)');
            return res.status(403).json({
                error: 'No autorizado para rechazar el escudo con este usuario_id',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 1. Marcar rechazo Y modal visto (para no volver a mostrarlo)
        await pool.query(
            `UPDATE escudos_conversacion 
             SET acepto = false, rechazo = true, modal_visto = true, fecha_respuesta = NOW()
             WHERE conversacion_id = $1 AND usuario_id = $2`,
            [conversacion_id, usuario_id]
        );

        // 2. Cerrar el chat para ambos
        await pool.query(
            `UPDATE conversaciones_app 
             SET chat_bloqueado = true, cerrado_por_escudo = true
             WHERE id = $1`,
            [conversacion_id]
        );

        // 3. Insertar mensaje de sistema
        await pool.query(
            `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
             VALUES ($1, 'SYSTEM', $2, '', NOW())`,
            [conversacion_id, `||ESCUDO_RECHAZADO||${usuario_id}`]
        );

        // 4. Avisar al otro (alerta + push)
        try {
            const convN = await pool.query(
                'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
                [conversacion_id]
            );
            const cN = convN.rows[0];
            if (cN) {
                const otroId = cN.usuario1_id === usuario_id ? cN.usuario2_id : cN.usuario1_id;
                const quien = await pool.query('SELECT nombre FROM usuarios WHERE uid = $1', [usuario_id]);
                const nombreQuien = quien.rows[0]?.nombre || 'El otro usuario';
                const textoAviso = `🛡️ ${nombreQuien} no aceptó el Escudo de Seguridad. El chat quedó cerrado.`;

                await pool.query(
                    `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
                     VALUES ($1, 0, $2, 'escudo_rechazado', NOW())`,
                    [otroId, textoAviso]
                );

                const tk = await pool.query('SELECT fcm_token FROM usuarios WHERE uid = $1', [otroId]);
                const token = tk.rows[0]?.fcm_token;
                if (token) {
                    try {
                        const { getMessaging } = require('firebase-admin/messaging');
                        await getMessaging().send({
                            token,
                            notification: {
                                title: '🛡️ Escudo rechazado',
                                body: `${nombreQuien} no aceptó el Escudo. El chat quedó cerrado.`,
                            },
                            data: { tipo: 'escudo_rechazado', conversacionId: conversacion_id.toString() },
                        });
                    } catch (e) {
                        console.error('>>> ❌ Error push escudo rechazado:', e.message);
                    }
                }
            }
        } catch (e) {
            console.error('>>> ❌ Error al avisar rechazo de escudo:', e.message);
        }

        console.log(`>>> 🛡️ Escudo rechazado por ${usuario_id}. Chat ${conversacion_id} cerrado.`);

        // 🔥 EMITIR POR WEBSOCKET
        global.broadcast(conversacion_id, {
            tipo: 'estado_cambio',
            estado: 'escudo_rechazado',
        });

        res.json({ success: true, chat_cerrado: true });
    } catch (error) {
        console.error('Error al rechazar escudo:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 📅 PROPUESTAS DE ENCUENTRO (NUEVO FLUJO)
// ============================================================

// 🔥 PROPONER ENCUENTRO (CON LUGAR SEGURO)
app.post('/api/encuentro/proponer', verificarTokenFirebase, async (req, res) => {
    try {
        const {
            conversacion_id,
            usuario_propone_id,
            usuario_recibe_id,
            lugar_id,
            fecha_encuentro,
        } = req.body;

        if (!conversacion_id || !usuario_propone_id || !usuario_recibe_id || !lugar_id || !fecha_encuentro) {
            return res.status(400).json({ error: 'Faltan datos obligatorios' });
        }

        console.log('>>> 🔐 Proponer encuentro. Usuario autenticado:', req.usuarioAutenticado);
        console.log('>>> 🔐 usuario_propone_id del body:', usuario_propone_id);

        // 🔥 Verificar que quien propone sea el usuario autenticado
        if (usuario_propone_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/encuentro/proponer');
            return res.status(403).json({
                error: 'No autorizado para proponer encuentros a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 Verificar que el usuario autenticado sea PARTE de la conversación
        const convCheck = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [conversacion_id]
        );
        if (convCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }
        const convData = convCheck.rows[0];
        if (convData.usuario1_id !== req.usuarioAutenticado && convData.usuario2_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de proponer encuentro en conversación ajena');
            return res.status(403).json({
                error: 'No autorizado para proponer encuentros en esta conversación',
                codigo: 'NO_ES_PARTE_DE_LA_CONVERSACION'
            });
        }

        const lugarResult = await pool.query(
            'SELECT * FROM lugares_seguros WHERE id = $1 AND activo = TRUE',
            [lugar_id]
        );

        if (lugarResult.rows.length === 0) {
            return res.status(400).json({ error: 'Lugar no válido' });
        }

        const lugar = lugarResult.rows[0];

        const result = await pool.query(
            `INSERT INTO propuestas_encuentro 
             (conversacion_id, usuario_propone_id, usuario_recibe_id, 
              provincia, canton, distrito, lugar_nombre, lugar_lat, lugar_lng, 
              fecha_encuentro, estado)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'pendiente')
             RETURNING *`,
            [
                conversacion_id, usuario_propone_id, usuario_recibe_id,
                lugar.provincia, lugar.canton, lugar.distrito || '',
                lugar.nombre, lugar.lat, lugar.lng,
                fecha_encuentro
            ]
        );

        // 🔥 CREAR MENSAJE EN EL CHAT
        await pool.query(
            `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
             VALUES ($1, $2, $3, $4, NOW())`,
            [
                conversacion_id,
                'SYSTEM',
                `||ENCUENTRO_PROPUESTA||${result.rows[0].id}`,
                ''
            ]
        );

        // 🔥 EMITIR POR WEBSOCKET
        global.broadcast(conversacion_id, {
            tipo: 'estado_cambio',
            estado: 'propuesta_encuentro',
        });

        console.log(`>>> 📅 Propuesta de encuentro creada: ${result.rows[0].id}`);
        res.status(201).json({ success: true, propuesta: result.rows[0] });
    } catch (error) {
        console.error('Error al crear propuesta:', error);
        res.status(500).json({ error: error.message });
    }
});

// 🔥 OBTENER PROPUESTA POR ID
app.get('/api/encuentro/propuesta/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const result = await pool.query(
            `SELECT * FROM propuestas_encuentro WHERE id = $1`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Propuesta no encontrada' });
        }

        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error al obtener propuesta:', error);
        res.status(500).json({ error: error.message });
    }
});

// 🔥 ACEPTAR PROPUESTA (RECHAZA AUTOMÁTICAMENTE LAS OTRAS)
app.put('/api/encuentro/propuesta/:id/aceptar', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;

        // 1. Obtener la propuesta que se va a aceptar
        const propuestaResult = await pool.query(
            `SELECT * FROM propuestas_encuentro WHERE id = $1`,
            [id]
        );

        if (propuestaResult.rows.length === 0) {
            return res.status(404).json({ error: 'Propuesta no encontrada' });
        }

        const propuesta = propuestaResult.rows[0];
        const conversacionId = propuesta.conversacion_id;

        // 🔥 Solo el usuario que RECIBE la propuesta puede aceptarla
        if (propuesta.usuario_recibe_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de aceptar propuesta ajena. User:', req.usuarioAutenticado, '| Recibe:', propuesta.usuario_recibe_id);
            return res.status(403).json({
                error: 'No autorizado para aceptar esta propuesta',
                codigo: 'NO_ES_EL_RECEPTOR'
            });
        }

        // 2. Aceptar esta propuesta
        const result = await pool.query(
            `UPDATE propuestas_encuentro 
             SET estado = 'aceptada', fecha_actualizacion = NOW()
             WHERE id = $1 RETURNING *`,
            [id]
        );

        // 3. Rechazar TODAS las otras propuestas pendientes de la misma conversación
        const rechazadas = await pool.query(
            `UPDATE propuestas_encuentro 
             SET estado = 'rechazada', fecha_actualizacion = NOW()
             WHERE conversacion_id = $1 
               AND id != $2
               AND estado = 'pendiente'
             RETURNING id`,
            [conversacionId, id]
        );

        console.log(`>>> ✅ Propuesta ${id} aceptada. ${rechazadas.rowCount} propuestas rechazadas automáticamente.`);

        // 4. Insertar mensaje de aceptación
        await pool.query(
            `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
             VALUES ($1, $2, $3, $4, NOW())`,
            [
                conversacionId,
                'SYSTEM',
                `||ENCUENTRO_ACEPTADO||${id}`,
                ''
            ]
        );

        // 🔥 EMITIR POR WEBSOCKET
        global.broadcast(conversacionId, {
            tipo: 'estado_cambio',
            estado: 'encuentro_aceptado',
        });

        // 🔥 ALERTA PARA QUIEN PROPUSO: su propuesta fue aceptada
        try {
            const quien = await pool.query(
                'SELECT nombre FROM usuarios WHERE uid = $1',
                [propuesta.usuario_recibe_id]
            );
            const nombreQuien = quien.rows[0]?.nombre || 'El otro usuario';
            const fechaTxt = new Date(propuesta.fecha_encuentro).toLocaleString('es-CR', { timeZone: 'America/Costa_Rica' });
            const ubicacion = [propuesta.lugar_nombre, propuesta.distrito, propuesta.canton, propuesta.provincia]
                .filter(x => x && x !== '')
                .join(', ');

            await pool.query(
                `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
                 VALUES ($1, 0, $2, 'encuentro', NOW()),
                        ($3, 0, $4, 'encuentro', NOW())`,
                [
                    propuesta.usuario_propone_id,
                    `✅ ${nombreQuien} aceptó tu propuesta de encuentro.\n📍 ${ubicacion}\n🕐 ${fechaTxt}\n\nEntra al chat para confirmar el trato o seguir conversando.`,
                    propuesta.usuario_recibe_id,
                    `✅ Aceptaste la propuesta de encuentro.\n📍 ${ubicacion}\n🕐 ${fechaTxt}\n\nEntra al chat para confirmar el trato o seguir conversando.`
                ]
            );
            console.log(`>>> 📥 Alerta de propuesta aceptada para ${propuesta.usuario_propone_id}`);
        } catch (e) {
            console.error('>>> ❌ Error al crear alerta de aceptación:', e.message);
        }

        // 5. Insertar mensaje de rechazo masivo (opcional, para que se vea en el chat)
        for (const r of rechazadas.rows) {
            await pool.query(
                `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
                 VALUES ($1, $2, $3, $4, NOW())`,
                [
                    conversacionId,
                    'SYSTEM',
                    `||ENCUENTRO_RECHAZADO||${r.id}`,
                    ''
                ]
            );
        }

        res.json({ 
            success: true, 
            propuesta: result.rows[0],
            rechazadas: rechazadas.rowCount,
        });
    } catch (error) {
        console.error('Error al aceptar propuesta:', error);
        res.status(500).json({ error: error.message });
    }
});

// 🔥 RECHAZAR PROPUESTA
app.put('/api/encuentro/propuesta/:id/rechazar', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;

        // 🔥 Primero verificar quién es el receptor
        const checkResult = await pool.query(
            `SELECT usuario_recibe_id FROM propuestas_encuentro WHERE id = $1`,
            [id]
        );

        if (checkResult.rows.length === 0) {
            return res.status(404).json({ error: 'Propuesta no encontrada' });
        }

        // 🔥 Solo el usuario que RECIBE la propuesta puede rechazarla
        if (checkResult.rows[0].usuario_recibe_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de rechazar propuesta ajena. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para rechazar esta propuesta',
                codigo: 'NO_ES_EL_RECEPTOR'
            });
        }

        const result = await pool.query(
            `UPDATE propuestas_encuentro 
             SET estado = 'rechazada', fecha_actualizacion = NOW()
             WHERE id = $1 RETURNING *`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Propuesta no encontrada' });
        }

        await pool.query(
            `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
             VALUES ($1, $2, $3, $4, NOW())`,
            [
                result.rows[0].conversacion_id,
                'SYSTEM',
                `||ENCUENTRO_RECHAZADO||${id}`,
                ''
            ]
        );

        res.json({ success: true, propuesta: result.rows[0] });
    } catch (error) {
        console.error('Error al rechazar propuesta:', error);
        res.status(500).json({ error: error.message });
    }
});

// 🔥 CONFIRMAR ENCUENTRO (SOLO CREA EL ENCUENTRO AGENDADO, NO BLOQUEA EL CHAT)
app.post('/api/encuentro/confirmar', verificarTokenFirebase, async (req, res) => {
    try {
        const { conversacion_id, usuario_confirma_id } = req.body;

        if (!conversacion_id || !usuario_confirma_id) {
            return res.status(400).json({ error: 'Faltan datos' });
        }

        console.log('>>> 🔐 Confirmar encuentro. Usuario autenticado:', req.usuarioAutenticado);
        console.log('>>> 🔐 usuario_confirma_id del body:', usuario_confirma_id);

        // 🔥 Verificar que el usuario_confirma_id coincida con el del token
        if (usuario_confirma_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/encuentro/confirmar');
            return res.status(403).json({
                error: 'No autorizado para confirmar encuentros a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 EL CHAT YA NO SE BLOQUEA ACÁ.
        // Se bloquea solo cuando AMBOS confirman cerrar trato (/api/conversaciones/:id/cerrar-trato).

        // 2. Obtener los datos del último encuentro aceptado
        const propuestaResult = await pool.query(
            `SELECT * FROM propuestas_encuentro 
             WHERE conversacion_id = $1 AND estado = 'aceptada'
             ORDER BY id DESC LIMIT 1`,
            [conversacion_id]
        );

        const propuesta = propuestaResult.rows[0];

        if (!propuesta) {
            return res.status(400).json({ error: 'No hay propuesta aceptada' });
        }

        // 3. Obtener los dos usuarios
        const convResult = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [conversacion_id]
        );
        const conv = convResult.rows[0];

        // 🔥 Verificar que el usuario autenticado sea PARTE de la conversación
        if (conv && conv.usuario1_id !== req.usuarioAutenticado && conv.usuario2_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de confirmar encuentro ajeno. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para confirmar este encuentro',
                codigo: 'NO_ES_PARTE_DE_LA_CONVERSACION'
            });
        }

        // 4. Insertar en encuentros_agendados (si no existe ya)
        const yaExiste = await pool.query(
            `SELECT id FROM encuentros_agendados 
             WHERE conversacion_id = $1 AND fecha_encuentro = $2`,
            [conversacion_id, propuesta.fecha_encuentro]
        );

        let encuentroId;
        if (yaExiste.rows.length > 0) {
            encuentroId = yaExiste.rows[0].id;
            console.log(`>>> 📅 Encuentro ya agendado: ${encuentroId}`);
        } else {
            const insertResult = await pool.query(
                `INSERT INTO encuentros_agendados 
                 (conversacion_id, usuario1_id, usuario2_id, fecha_encuentro, 
                  lugar_nombre, lugar_lat, lugar_lng, estado, escudo_verificado)
                 VALUES ($1, $2, $3, $4, $5, $6, $7, 'agendado', false)
                 RETURNING *`,
                [
                    conversacion_id,
                    conv.usuario1_id,
                    conv.usuario2_id,
                    propuesta.fecha_encuentro,
                    propuesta.lugar_nombre || '',
                    propuesta.lugar_lat || null,
                    propuesta.lugar_lng || null,
                ]
            );
            encuentroId = insertResult.rows[0].id;
            console.log(`>>> 📅 Encuentro agendado creado: ${encuentroId}`);
        }

        // 5. Crear alerta para los dos
        const mensajeAlerta = `📅 Encuentro confirmado.\n📍 ${propuesta.lugar_nombre}, ${propuesta.distrito}, ${propuesta.canton}, ${propuesta.provincia}\n🕐 ${new Date(propuesta.fecha_encuentro).toLocaleString('es-CR')}\n\n⚠️ No llegues tarde.\n🔒 Se pedirá reconocimiento facial.\n📍 Se activará GPS el día del encuentro.\n💬 El chat queda bloqueado hasta que se vean.`;

        await pool.query(
            `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
             VALUES ($1, $2, $3, 'encuentro', NOW()), ($4, $2, $3, 'encuentro', NOW())`,
            [conv.usuario1_id, 0, mensajeAlerta, conv.usuario2_id]
        );

        console.log(`>>> ✅ Encuentro confirmado para conversación ${conversacion_id}`);
        res.json({ 
            success: true, 
            bloqueado: true, 
            propuesta,
            encuentro_id: encuentroId,
        });
    } catch (error) {
        console.error('>>> ❌ Error al confirmar encuentro:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔥 SEGUIR CONVERSANDO (mutuo)
// ============================================================

// POST - Marcar que un usuario quiere seguir conversando
app.post('/api/conversaciones/:id/seguir-conversando', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;
        const { usuario_id } = req.body;

        if (!usuario_id) {
            return res.status(400).json({ error: 'usuario_id requerido' });
        }

        console.log('>>> 🔄 Seguir conversando. Usuario autenticado:', req.usuarioAutenticado);
        console.log('>>> 🔄 Usuario del body:', usuario_id);

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en seguir-conversando');
            return res.status(403).json({
                error: 'No autorizado para seguir conversando con este usuario_id',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 Quien decide seguir apaga el cierre de trato pendiente.
        // 🔥 1. Resetear la bandera quiere_cerrar_trato.
        await pool.query(
            'UPDATE conversaciones_app SET quiere_cerrar_trato = false WHERE id = $1',
            [id]
        );

        // 🔥 2. Borrar los ||CERRAR_TRATO|| para que el otro no siga viendo el cartel azul.
        await pool.query(
            `DELETE FROM mensajes_app 
             WHERE conversacion_id = $1 
               AND texto LIKE '||CERRAR_TRATO||%'`,
            [id]
        );
        console.log(`>>> 🧹 "Cerrar trato" borrado por "seguir conversando"`);

        // Insertar en seguimiento_conversacion (por si acaso)
        await pool.query(
            `INSERT INTO seguimiento_conversacion (conversacion_id, usuario_id)
             VALUES ($1, $2)
             ON CONFLICT (conversacion_id, usuario_id) DO NOTHING`,
            [id, usuario_id]
        );

        // 🔥 CONTAR LEYENDO LOS MENSAJES (no la tabla nueva)
        const result = await pool.query(
            `SELECT DISTINCT usuario_id 
             FROM mensajes_app 
             WHERE conversacion_id = $1 
               AND texto LIKE '||SEGUIR_CONVERSANDO||%'`,
            [id]
        );

        const total = result.rows.length;
        const ambosSeguir = total >= 2;

        // 🔥 EMITIR POR WEBSOCKET
        global.broadcast(id, {
            tipo: 'estado_cambio',
            estado: 'seguir_conversando',
        });

        console.log(`>>> 🟢 Seguir conversando: conv=${id}, user=${usuario_id}, total=${total}, ambos=${ambosSeguir}`);

        // 🔥 SI AMBOS QUIEREN SEGUIR, INSERTAR MENSAJE EN EL CHAT
        if (ambosSeguir) {
            // Verificar que no exista ya
            const yaExiste = await pool.query(
                `SELECT id FROM mensajes_app 
                 WHERE conversacion_id = $1 
                   AND texto = '||AMBOS_SEGUIR_CONVERSANDO||'
                 LIMIT 1`,
                [id]
            );
            if (yaExiste.rows.length === 0) {
                await pool.query(
                    `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
                     VALUES ($1, 'SYSTEM', '||AMBOS_SEGUIR_CONVERSANDO||', '', NOW())`,
                    [id]
                );
                console.log(`>>> ✅ Mensaje "ambos seguir" insertado en conv ${id}`);
            }
        }

        res.json({
            success: true,
            ambos_seguir: ambosSeguir,
            total_usuarios: total,
        });
    } catch (error) {
        console.error('Error al marcar seguir conversando:', error);
        res.status(500).json({ error: error.message });
    }
});

// GET - Consultar si ambos quieren seguir
app.get('/api/conversaciones/:id/seguir-conversando', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;

        // 🔥 Verificar que el usuario autenticado sea PARTE de la conversación
        const convCheck = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [id]
        );
        if (convCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }
        const convData = convCheck.rows[0];
        if (convData.usuario1_id !== req.usuarioAutenticado && convData.usuario2_id !== req.usuarioAutenticado) {
            return res.status(403).json({
                error: 'No autorizado para ver el estado de esta conversación',
                codigo: 'NO_ES_PARTE_DE_LA_CONVERSACION'
            });
        }

        // 🔥 LEER DE LOS MENSAJES, NO DE LA TABLA NUEVA
        const result = await pool.query(
            `SELECT DISTINCT usuario_id 
             FROM mensajes_app 
             WHERE conversacion_id = $1 
               AND texto LIKE '||SEGUIR_CONVERSANDO||%'`,
            [id]
        );

        const usuarios = result.rows.map(r => r.usuario_id);
        console.log(`>>> 🟢 GET seguir-conversando conv=${id}: usuarios=${JSON.stringify(usuarios)}`);
        res.json({
            ambos_seguir: usuarios.length >= 2,
            usuarios: usuarios,
        });
    } catch (error) {
        console.error('Error al consultar seguir conversando:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔥 CERRAR TRATO (mutuo)
// ============================================================

// POST - Marcar que un usuario confirma cerrar el trato
app.post('/api/conversaciones/:id/cerrar-trato', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;
        const { usuario_id } = req.body;

        if (!usuario_id) {
            return res.status(400).json({ error: 'usuario_id requerido' });
        }

        console.log('>>> 🤝 Cerrar trato. Usuario autenticado:', req.usuarioAutenticado);
        console.log('>>> 🤝 Usuario del body:', usuario_id);

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en cerrar-trato');
            return res.status(403).json({
                error: 'No autorizado para cerrar trato con este usuario_id',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 VERIFICAR QUE NO EXISTA YA (para no duplicar)
        const yaExiste = await pool.query(
            `SELECT id FROM mensajes_app 
             WHERE conversacion_id = $1 
               AND texto = $2
             LIMIT 1`,
            [id, `||CERRAR_TRATO||${usuario_id}`]
        );

        if (yaExiste.rows.length === 0) {
            await pool.query(
                `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
                 VALUES ($1, $2, $3, '', NOW())`,
                [id, usuario_id, `||CERRAR_TRATO||${usuario_id}`]
            );

            // 🔥 EMITIR POR WEBSOCKET
            global.broadcast(id, {
                tipo: 'estado_cambio',
                estado: 'cerrar_trato',
            });

            // 🔥 AVISAR AL OTRO USUARIO (alerta + push) si todavía no confirmó
            try {
                const convN = await pool.query(
                    'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
                    [id]
                );
                const cN = convN.rows[0];
                if (cN) {
                    const otroId = cN.usuario1_id === usuario_id ? cN.usuario2_id : cN.usuario1_id;

                    const otroYaConfirmo = await pool.query(
                        `SELECT id FROM mensajes_app 
                         WHERE conversacion_id = $1 AND texto = $2 LIMIT 1`,
                        [id, `||CERRAR_TRATO||${otroId}`]
                    );

                    if (otroYaConfirmo.rows.length === 0) {
                        const quien = await pool.query('SELECT nombre FROM usuarios WHERE uid = $1', [usuario_id]);
                        const nombreQuien = quien.rows[0]?.nombre || 'El otro usuario';
                        const textoAviso = `🤝 ${nombreQuien} quiere cerrar el trato.\n\nEntra al chat para confirmar o seguir conversando.`;

                        await pool.query(
                            `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
                             VALUES ($1, 0, $2, 'encuentro', NOW())`,
                            [otroId, textoAviso]
                        );

                        const tk = await pool.query('SELECT fcm_token FROM usuarios WHERE uid = $1', [otroId]);
                        const token = tk.rows[0]?.fcm_token;
                        if (token) {
                            try {
                                const { getMessaging } = require('firebase-admin/messaging');
                                await getMessaging().send({
                                    token,
                                    notification: {
                                        title: '🤝 Quieren cerrar el trato',
                                        body: `${nombreQuien} confirmó. Entra al chat para decidir.`,
                                    },
                                    data: { tipo: 'cerrar_trato', conversacionId: id.toString() },
                                });
                                console.log(`>>> 📨 Push cerrar-trato enviada a ${otroId}`);
                            } catch (e) {
                                console.error('>>> ❌ Error push cerrar-trato:', e.message);
                            }
                        }
                        console.log(`>>> 📥 Alerta "quiere cerrar trato" creada para ${otroId}`);
                    }
                }
            } catch (e) {
                console.error('>>> ❌ Error al avisar cierre de trato:', e.message);
            }
        }

        // 🔥 CONTAR CUÁNTOS CONFIRMARON
        const result = await pool.query(
            `SELECT DISTINCT usuario_id 
             FROM mensajes_app 
             WHERE conversacion_id = $1 
               AND texto LIKE '||CERRAR_TRATO||%'`,
            [id]
        );

        const usuarios = result.rows.map(r => r.usuario_id);
        const ambos = usuarios.length >= 2;

        console.log(`>>> 🟢 Cerrar trato: conv=${id}, user=${usuario_id}, total=${usuarios.length}, ambos=${ambos}`);

        // 🔥 SI AMBOS CONFIRMARON, INSERTAR MENSAJE FINAL Y CREAR ENCUENTRO AGENDADO
        if (ambos) {
            const yaExisteFinal = await pool.query(
                `SELECT id FROM mensajes_app 
                 WHERE conversacion_id = $1 
                   AND texto = '||TRATO_CERRADO||'
                 LIMIT 1`,
                [id]
            );
            if (yaExisteFinal.rows.length === 0) {
                await pool.query(
                    `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
                     VALUES ($1, 'SYSTEM', '||TRATO_CERRADO||', '', NOW())`,
                    [id]
                );
                console.log(`>>> ✅ Trato CERRADO en conv ${id}`);

                // 🔥 AHORA SÍ: BLOQUEAR EL CHAT (solo cuando ambos confirmaron)
                await pool.query(
                    `UPDATE conversaciones_app 
                     SET chat_bloqueado = TRUE 
                     WHERE id = $1`,
                    [id]
                );
                console.log(`>>> 🔒 Chat bloqueado en conv ${id} (ambos confirmaron trato)`);

                // 🔥 ALERTA PARA LOS DOS: trato cerrado
                try {
                    const propAlerta = await pool.query(
                        `SELECT * FROM propuestas_encuentro 
                         WHERE conversacion_id = $1 AND estado = 'aceptada'
                         ORDER BY id DESC LIMIT 1`,
                        [id]
                    );
                    const convAlerta = await pool.query(
                        'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
                        [id]
                    );
                    const p = propAlerta.rows[0];
                    const c = convAlerta.rows[0];

                    if (p && c) {
                        const fechaTxt = new Date(p.fecha_encuentro).toLocaleString('es-CR', { timeZone: 'America/Costa_Rica' });
                        const ubicacion = [p.lugar_nombre, p.distrito, p.canton, p.provincia]
                            .filter(x => x && x !== '')
                            .join(', ');
                        const mensajeAlerta = `🤝 Trato cerrado. Encuentro confirmado.\n📍 ${ubicacion}\n🕐 ${fechaTxt}\n\n⚠️ No llegues tarde.\n🔒 Se pedirá reconocimiento facial.\n📍 Se activará el GPS el día del encuentro.\n💬 El chat queda bloqueado hasta que se vean.`;

                        await pool.query(
                            `INSERT INTO alertas (usuario_id, producto_id, mensaje, tipo, fecha) 
                             VALUES ($1, 0, $3, 'encuentro', NOW()), ($2, 0, $3, 'encuentro', NOW())`,
                            [c.usuario1_id, c.usuario2_id, mensajeAlerta]
                        );
                        console.log(`>>> 📥 Alertas de trato cerrado insertadas para conv ${id}`);
                    }
                } catch (e) {
                    console.error('>>> ❌ Error al crear alerta de trato cerrado:', e.message);
                }
            }

            // 🔥 BUSCAR LA PROPUESTA ACEPTADA Y CREAR ENCUENTRO AGENDADO
            const propuestaResult = await pool.query(
                `SELECT * FROM propuestas_encuentro 
                 WHERE conversacion_id = $1 AND estado = 'aceptada'
                 ORDER BY id DESC LIMIT 1`,
                [id]
            );

            if (propuestaResult.rows.length > 0) {
                const propuesta = propuestaResult.rows[0];

                // Obtener los dos usuarios
                const convResult = await pool.query(
                    'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
                    [id]
                );
                const conv = convResult.rows[0];

                // Verificar si ya existe el encuentro agendado
                const yaAgendado = await pool.query(
                    `SELECT id FROM encuentros_agendados 
                     WHERE conversacion_id = $1 AND fecha_encuentro = $2`,
                    [id, propuesta.fecha_encuentro]
                );

                if (yaAgendado.rows.length === 0) {
                    const insertResult = await pool.query(
                        `INSERT INTO encuentros_agendados 
                         (conversacion_id, usuario1_id, usuario2_id, fecha_encuentro, 
                          lugar_nombre, lugar_lat, lugar_lng, estado, escudo_verificado)
                         VALUES ($1, $2, $3, $4, $5, $6, $7, 'agendado', false)
                         RETURNING *`,
                        [
                            id,
                            conv.usuario1_id,
                            conv.usuario2_id,
                            propuesta.fecha_encuentro,
                            propuesta.lugar_nombre || '',
                            propuesta.lugar_lat || null,
                            propuesta.lugar_lng || null,
                        ]
                    );
                    console.log(`>>> 📅 Encuentro agendado creado: ${insertResult.rows[0].id}`);


                } else {
                    console.log(`>>> 📅 Encuentro ya agendado: ${yaAgendado.rows[0].id}`);
                }
            } else {
                console.log(`>>> ⚠️ No hay propuesta aceptada para conv ${id}`);
            }
        }

        res.json({
            success: true,
            ambos_confirmaron: ambos,
            usuarios: usuarios,
        });
    } catch (error) {
        console.error('Error al cerrar trato:', error);
        res.status(500).json({ error: error.message });
    }
});
// POST - Cancelar cierre de trato
app.post('/api/conversaciones/:id/cancelar-cierre-trato', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;

        // 🔥 Verificar que el usuario autenticado sea PARTE de la conversación
        const convCheck = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [id]
        );
        if (convCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }
        const convData = convCheck.rows[0];
        if (convData.usuario1_id !== req.usuarioAutenticado && convData.usuario2_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de cancelar cierre de trato ajeno. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para cancelar el cierre de trato en esta conversación',
                codigo: 'NO_ES_PARTE_DE_LA_CONVERSACION'
            });
        }

        await pool.query(
            `UPDATE conversaciones_app 
             SET quiere_cerrar_trato = false,
                 fecha_analisis = NOW()
             WHERE id = $1`,
            [id]
        );

        console.log(`>>> 🚫 Cierre de trato cancelado en conv ${id}`);
        res.json({ success: true });
    } catch (error) {
        console.error('Error al cancelar cierre de trato:', error);
        res.status(500).json({ error: error.message });
    }
});

// GET - Consultar quién confirmó cerrar trato
app.get('/api/conversaciones/:id/cerrar-trato', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;

        // 🔥 Verificar que el usuario autenticado sea PARTE de la conversación
        const convCheck = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [id]
        );
        if (convCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }
        const convData = convCheck.rows[0];
        if (convData.usuario1_id !== req.usuarioAutenticado && convData.usuario2_id !== req.usuarioAutenticado) {
            return res.status(403).json({
                error: 'No autorizado para ver el estado de esta conversación',
                codigo: 'NO_ES_PARTE_DE_LA_CONVERSACION'
            });
        }

        const result = await pool.query(
            `SELECT DISTINCT usuario_id 
             FROM mensajes_app 
             WHERE conversacion_id = $1 
               AND texto LIKE '||CERRAR_TRATO||%'`,
            [id]
        );

        const usuarios = result.rows.map(r => r.usuario_id);
        console.log(`>>> 🟢 GET cerrar-trato conv=${id}: usuarios=${JSON.stringify(usuarios)}`);
        res.json({
            ambos_confirmaron: usuarios.length >= 2,
            usuarios: usuarios,
        });
    } catch (error) {
        console.error('Error al consultar cerrar trato:', error);
        res.status(500).json({ error: error.message });
    }
});

// 🔥 CONTRAPROPUESTA
app.put('/api/encuentro/propuesta/:id/contrapropuesta', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;
        const {
            usuario_id,
            lugar_nombre,
            lugar_lat,
            lugar_lng,
            fecha_encuentro,
        } = req.body;

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en contrapropuesta');
            return res.status(403).json({
                error: 'No autorizado para hacer contrapropuestas a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 Verificar que el usuario autenticado sea PARTE de la propuesta
        const propCheck = await pool.query(
            'SELECT usuario_propone_id, usuario_recibe_id FROM propuestas_encuentro WHERE id = $1',
            [id]
        );
        if (propCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Propuesta no encontrada' });
        }
        const propData = propCheck.rows[0];
        if (propData.usuario_propone_id !== req.usuarioAutenticado && propData.usuario_recibe_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de contrapropuesta en propuesta ajena. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para hacer contrapropuestas en esta propuesta',
                codigo: 'NO_ES_PARTE_DE_LA_PROPUESTA'
            });
        }

        const result = await pool.query(
            `UPDATE propuestas_encuentro 
             SET estado = 'contrapropuesta',
                 contrapropuesta_de_id = $1,
                 contrapropuesta_lugar = $2,
                 contrapropuesta_fecha = $3,
                 fecha_actualizacion = NOW()
             WHERE id = $4 RETURNING *`,
            [usuario_id, lugar_nombre, fecha_encuentro, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Propuesta no encontrada' });
        }

        await pool.query(
            `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
             VALUES ($1, $2, $3, $4, NOW())`,
            [
                result.rows[0].conversacion_id,
                'SYSTEM',
                `||ENCUENTRO_CONTRAPROPUESTA||${id}`,
                ''
            ]
        );

        res.json({ success: true, propuesta: result.rows[0] });
    } catch (error) {
        console.error('Error al hacer contrapropuesta:', error);
        res.status(500).json({ error: error.message });
    }
});

// 🔥 CONFIRMAR PROPUESTA FINAL
app.put('/api/encuentro/propuesta/:id/confirmar', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;

        // 🔥 Verificar que el usuario autenticado sea PARTE de la propuesta
        const propCheck = await pool.query(
            'SELECT usuario_propone_id, usuario_recibe_id FROM propuestas_encuentro WHERE id = $1',
            [id]
        );
        if (propCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Propuesta no encontrada' });
        }
        const propData = propCheck.rows[0];
        if (propData.usuario_propone_id !== req.usuarioAutenticado && propData.usuario_recibe_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de confirmar propuesta ajena. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para confirmar esta propuesta',
                codigo: 'NO_ES_PARTE_DE_LA_PROPUESTA'
            });
        }

        const result = await pool.query(
            `UPDATE propuestas_encuentro 
             SET estado = 'confirmada', fecha_actualizacion = NOW()
             WHERE id = $1 RETURNING *`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Propuesta no encontrada' });
        }

        res.json({ success: true, propuesta: result.rows[0] });
    } catch (error) {
        console.error('Error al confirmar propuesta:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 📅 ENCUENTROS AGENDADOS
// ============================================================

// AGENDAR ENCUENTRO
app.post('/api/encuentro/agendar', verificarTokenFirebase, async (req, res) => {
    try {
        const {
            conversacion_id,
            usuario1_id,
            usuario2_id,
            fecha_encuentro,
            lugar_nombre,
            lugar_lat,
            lugar_lng,
        } = req.body;

        if (!conversacion_id || !usuario1_id || !usuario2_id || !fecha_encuentro) {
            return res.status(400).json({ error: 'Faltan datos obligatorios' });
        }

        // 🔥 Verificar que el usuario autenticado sea uno de los dos participantes
        if (usuario1_id !== req.usuarioAutenticado && usuario2_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de agendar encuentro a nombre de otros. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para agendar encuentros a nombre de otros usuarios',
                codigo: 'NO_ES_PARTE_DEL_ENCUENTRO'
            });
        }

        // 🔥 Verificar que el usuario autenticado sea PARTE de la conversación
        const convCheck = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM conversaciones_app WHERE id = $1',
            [conversacion_id]
        );
        if (convCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }
        const convData = convCheck.rows[0];
        if (convData.usuario1_id !== req.usuarioAutenticado && convData.usuario2_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de agendar encuentro en conversación ajena');
            return res.status(403).json({
                error: 'No autorizado para agendar encuentros en esta conversación',
                codigo: 'NO_ES_PARTE_DE_LA_CONVERSACION'
            });
        }

        const result = await pool.query(
            `INSERT INTO encuentros_agendados 
             (conversacion_id, usuario1_id, usuario2_id, fecha_encuentro, lugar_nombre, lugar_lat, lugar_lng)
             VALUES ($1, $2, $3, $4, $5, $6, $7)
             RETURNING *`,
            [conversacion_id, usuario1_id, usuario2_id, fecha_encuentro, lugar_nombre || '', lugar_lat || null, lugar_lng || null]
        );

        console.log(`>>> 📅 Encuentro agendado: ${result.rows[0].id}`);
        res.status(201).json({ success: true, encuentro: result.rows[0] });
    } catch (error) {
        console.error('Error al agendar encuentro:', error);
        res.status(500).json({ error: error.message });
    }
});

// OBTENER PRÓXIMO ENCUENTRO DE UN USUARIO
app.get('/api/encuentro/proximo/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;
        const result = await pool.query(
            `SELECT * FROM encuentros_agendados 
             WHERE (usuario1_id = $1 OR usuario2_id = $1)
             AND estado = 'agendado'
             AND fecha_encuentro > NOW()
             ORDER BY fecha_encuentro ASC
             LIMIT 1`,
            [usuario_id]
        );

        if (result.rows.length === 0) {
            return res.json({ encuentro: null });
        }

        res.json({ encuentro: result.rows[0] });
    } catch (error) {
        console.error('Error al obtener próximo encuentro:', error);
        res.status(500).json({ error: error.message });
    }
});

// OBTENER ENCUENTRO POR CONVERSACIÓN
app.get('/api/encuentro/conversacion/:conversacion_id', async (req, res) => {
    try {
        const { conversacion_id } = req.params;

        // 🔥 BUSCAR EN propuestas_encuentro (no en encuentros_agendados)
        const result = await pool.query(
            `SELECT * FROM propuestas_encuentro 
             WHERE conversacion_id = $1
             ORDER BY id DESC
             LIMIT 1`,
            [conversacion_id]
        );

        if (result.rows.length === 0) {
            return res.json({ encuentro: null });
        }

        console.log(`>>> 🟢 Encuentro encontrado para conv ${conversacion_id}: propuesta ${result.rows[0].id} (estado: ${result.rows[0].estado})`);
        res.json({ encuentro: result.rows[0] });
    } catch (error) {
        console.error('Error al obtener encuentro:', error);
        res.status(500).json({ error: error.message });
    }
});

// CANCELAR ENCUENTRO
app.post('/api/encuentro/cancelar/:id', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;

        // 🔥 Verificar que el usuario autenticado sea PARTE del encuentro
        const encCheck = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM encuentros_agendados WHERE id = $1',
            [id]
        );
        if (encCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Encuentro no encontrado' });
        }
        const encData = encCheck.rows[0];
        if (encData.usuario1_id !== req.usuarioAutenticado && encData.usuario2_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de cancelar encuentro ajeno. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para cancelar este encuentro',
                codigo: 'NO_ES_PARTE_DEL_ENCUENTRO'
            });
        }

        const result = await pool.query(
            `UPDATE encuentros_agendados 
             SET estado = 'cancelado' 
             WHERE id = $1
             RETURNING *`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Encuentro no encontrado' });
        }

        res.json({ success: true, encuentro: result.rows[0] });
    } catch (error) {
        console.error('Error al cancelar encuentro:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔐 VERIFICACIÓN FACIAL
// ============================================================

app.post('/api/encuentro/verificar-facial', verificarTokenFirebase, async (req, res) => {
    try {
        const { encuentro_id, usuario_id, aprobado, confianza, selfie_base64 } = req.body;

        if (!encuentro_id || !usuario_id) {
            return res.status(400).json({ error: 'Faltan datos' });
        }

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/encuentro/verificar-facial');
            return res.status(403).json({
                error: 'No autorizado para verificar identidad a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 Verificar que el usuario autenticado sea PARTE del encuentro
        const encCheck = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM encuentros_agendados WHERE id = $1',
            [encuentro_id]
        );
        if (encCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Encuentro no encontrado' });
        }
        const encData = encCheck.rows[0];
        if (encData.usuario1_id !== req.usuarioAutenticado && encData.usuario2_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de verificar encuentro ajeno. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para verificar este encuentro',
                codigo: 'NO_ES_PARTE_DEL_ENCUENTRO'
            });
        }

        // 🔥 GUARDAR LA SELFIE SI VIENE EN BASE64
        let fotoSelfieUrl = null;
        if (selfie_base64 && selfie_base64.length > 0) {
            try {
                // Crear carpeta si no existe
                const selfiesDir = path.join(__dirname, 'uploads/selfies');
                if (!fs.existsSync(selfiesDir)) {
                    fs.mkdirSync(selfiesDir, { recursive: true });
                }

                // Convertir base64 a buffer
                const base64Data = selfie_base64.replace(/^data:image\/\w+;base64,/, '');
                const buffer = Buffer.from(base64Data, 'base64');

                // Nombre único
                const filename = `selfie_${encuentro_id}_${usuario_id}_${Date.now()}.jpg`;
                const filepath = path.join(selfiesDir, filename);

                // Guardar archivo
                fs.writeFileSync(filepath, buffer);
                fotoSelfieUrl = `/uploads/selfies/${filename}`;

                console.log(`>>> 📸 Selfie guardada: ${fotoSelfieUrl}`);
            } catch (e) {
                console.error('>>> ❌ Error guardando selfie:', e.message);
            }
        }

        const result = await pool.query(
            `INSERT INTO verificaciones_faciales 
             (encuentro_id, usuario_id, aprobado, confianza, foto_selfie, fecha_selfie)
             VALUES ($1, $2, $3, $4, $5, NOW())
             RETURNING *`,
            [encuentro_id, usuario_id, aprobado === true, confianza || 0, fotoSelfieUrl]
        );

        // Si el usuario verifica OK, marcar en el encuentro
        if (aprobado === true) {
            await pool.query(
                `UPDATE encuentros_agendados 
                 SET escudo_verificado = true 
                 WHERE id = $1`,
                [encuentro_id]
            );
        }

        res.status(201).json({ 
            success: true, 
            verificacion: result.rows[0],
            foto_selfie: fotoSelfieUrl,
        });
    } catch (error) {
        console.error('Error al guardar verificación facial:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 📍 GPS TRACKING
// ============================================================

app.post('/api/encuentro/gps', verificarTokenFirebase, async (req, res) => {
    try {
        const { encuentro_id, usuario_id, lat, lng } = req.body;

        if (!encuentro_id || !usuario_id || lat === undefined || lng === undefined) {
            return res.status(400).json({ error: 'Faltan datos' });
        }

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/encuentro/gps');
            return res.status(403).json({
                error: 'No autorizado para enviar GPS a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // 🔥 Verificar que el usuario autenticado sea PARTE del encuentro
        const encCheck = await pool.query(
            'SELECT usuario1_id, usuario2_id FROM encuentros_agendados WHERE id = $1',
            [encuentro_id]
        );
        if (encCheck.rows.length === 0) {
            return res.status(404).json({ error: 'Encuentro no encontrado' });
        }
        const encData = encCheck.rows[0];
        if (encData.usuario1_id !== req.usuarioAutenticado && encData.usuario2_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de enviar GPS a encuentro ajeno. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para enviar GPS a este encuentro',
                codigo: 'NO_ES_PARTE_DEL_ENCUENTRO'
            });
        }

        const result = await pool.query(
            `INSERT INTO gps_tracking (encuentro_id, usuario_id, lat, lng)
             VALUES ($1, $2, $3, $4)
             RETURNING *`,
            [encuentro_id, usuario_id, lat, lng]
        );

        res.status(201).json({ success: true, tracking: result.rows[0] });
    } catch (error) {
        console.error('Error al guardar GPS:', error);
        res.status(500).json({ error: error.message });
    }
});

// OBTENER HISTORIAL GPS DE UN ENCUENTRO
app.get('/api/encuentro/gps/:encuentro_id', async (req, res) => {
    try {
        const { encuentro_id } = req.params;
        const result = await pool.query(
            `SELECT * FROM gps_tracking 
             WHERE encuentro_id = $1
             ORDER BY fecha ASC`,
            [encuentro_id]
        );
        res.json(result.rows);
    } catch (error) {
        console.error('Error al obtener GPS:', error);
        res.status(500).json({ error: error.message });
    }
});
// ============================================================
// 🔥 LUGARES SEGUROS - PROVINCIAS DISPONIBLES
// ============================================================
app.get('/api/lugares-seguros/provincias', async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT DISTINCT provincia FROM lugares_seguros 
             WHERE activo = TRUE 
             ORDER BY provincia`
        );
        res.json(result.rows.map(r => r.provincia));
    } catch (error) {
        console.error('Error al obtener provincias:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔥 LUGARES SEGUROS - CANTONES DISPONIBLES POR PROVINCIA
// ============================================================
app.get('/api/lugares-seguros/cantones', async (req, res) => {
    try {
        const { provincia } = req.query;
        if (!provincia) {
            return res.status(400).json({ error: 'provincia requerida' });
        }
        const result = await pool.query(
            `SELECT DISTINCT canton FROM lugares_seguros 
             WHERE activo = TRUE AND provincia = $1
             ORDER BY canton`,
            [provincia]
        );
        res.json(result.rows.map(r => r.canton));
    } catch (error) {
        console.error('Error al obtener cantones:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔥 LUGARES SEGUROS - DISTRITOS DISPONIBLES POR PROVINCIA Y CANTÓN
// ============================================================
app.get('/api/lugares-seguros/distritos', async (req, res) => {
    try {
        const { provincia, canton } = req.query;
        if (!provincia || !canton) {
            return res.status(400).json({ error: 'provincia y canton requeridos' });
        }
        const result = await pool.query(
            `SELECT DISTINCT distrito FROM lugares_seguros 
             WHERE activo = TRUE AND provincia = $1 AND canton = $2
             ORDER BY distrito`,
            [provincia, canton]
        );
        res.json(result.rows.map(r => r.distrito).filter(d => d && d !== ''));
    } catch (error) {
        console.error('Error al obtener distritos:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔥 LUGARES SEGUROS - LISTA CON FILTROS
// ============================================================
// ============================================================
// 🔥 VERIFICAR SI EL USUARIO ESTÁ CERCA DEL LUGAR
// ============================================================
app.post('/api/encuentro/:id/verificar-ubicacion', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;
        const { usuario_id, lat, lng } = req.body;

        if (!usuario_id || lat === undefined || lng === undefined) {
            return res.status(400).json({ error: 'Faltan datos' });
        }

        // 🔥 Verificar que el usuario_id del body coincida con el del token
        if (usuario_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ UID no coincide en POST /api/encuentro/:id/verificar-ubicacion');
            return res.status(403).json({
                error: 'No autorizado para verificar ubicación a nombre de otro usuario',
                codigo: 'UID_NO_COINCIDE'
            });
        }

        // Obtener el encuentro
        const encResult = await pool.query(
            `SELECT * FROM encuentros_agendados WHERE id = $1`,
            [id]
        );

        if (encResult.rows.length === 0) {
            return res.status(404).json({ error: 'Encuentro no encontrado' });
        }

        const enc = encResult.rows[0];

        // 🔥 Verificar que el usuario autenticado sea PARTE del encuentro
        if (enc.usuario1_id !== req.usuarioAutenticado && enc.usuario2_id !== req.usuarioAutenticado) {
            console.log('>>> ❌ Intento de verificar ubicación en encuentro ajeno. User:', req.usuarioAutenticado);
            return res.status(403).json({
                error: 'No autorizado para verificar ubicación en este encuentro',
                codigo: 'NO_ES_PARTE_DEL_ENCUENTRO'
            });
        }

        if (enc.lugar_lat === null || enc.lugar_lng === null) {
            return res.status(400).json({ error: 'El encuentro no tiene coordenadas' });
        }

        // Distancia en metros (fórmula de Haversine)
        const R = 6371000; // radio de la Tierra en metros
        const lat1 = parseFloat(lat) * Math.PI / 180;
        const lat2 = parseFloat(enc.lugar_lat) * Math.PI / 180;
        const dLat = (parseFloat(enc.lugar_lat) - parseFloat(lat)) * Math.PI / 180;
        const dLng = (parseFloat(enc.lugar_lng) - parseFloat(lng)) * Math.PI / 180;

        const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                  Math.cos(lat1) * Math.cos(lat2) *
                  Math.sin(dLng/2) * Math.sin(dLng/2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        const distanciaMetros = R * c;

        const RADIO_PERMITIDO = 150; // metros
        const enLugar = distanciaMetros <= RADIO_PERMITIDO;

        // Guardar tracking en cualquier caso
        await pool.query(
            `INSERT INTO gps_tracking (encuentro_id, usuario_id, lat, lng)
             VALUES ($1, $2, $3, $4)`,
            [id, usuario_id, lat, lng]
        );

        console.log(`>>> 📍 Usuario ${usuario_id} a ${Math.round(distanciaMetros)}m del lugar (${enLugar ? 'DENTRO' : 'FUERA'})`);

        res.json({
            en_lugar: enLugar,
            distancia_metros: Math.round(distanciaMetros),
            radio_permitido: RADIO_PERMITIDO,
        });
    } catch (error) {
        console.error('Error al verificar ubicación:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔥 ESTADO DEL ENCUENTRO (verifica si ambos están presentes)
// ============================================================
app.get('/api/encuentro/:id/estado', async (req, res) => {
    try {
        const { id } = req.params;

        // 1. Obtener el encuentro
        const encResult = await pool.query(
            `SELECT * FROM encuentros_agendados WHERE id = $1`,
            [id]
        );

        if (encResult.rows.length === 0) {
            return res.status(404).json({ error: 'Encuentro no encontrado' });
        }

        const enc = encResult.rows[0];

        // 2. Verificar cuántos usuarios verificaron facialmente
        const verifResult = await pool.query(
            `SELECT DISTINCT usuario_id 
             FROM verificaciones_faciales 
             WHERE encuentro_id = $1 AND aprobado = TRUE`,
            [id]
        );

        const usuariosVerificados = verifResult.rows.map(r => r.usuario_id);
        const ambosPresentes = 
            usuariosVerificados.includes(enc.usuario1_id) && 
            usuariosVerificados.includes(enc.usuario2_id);

        // 3. Si ambos están presentes, desbloquear el chat
        if (ambosPresentes) {
            await pool.query(
                `UPDATE conversaciones_app 
                 SET chat_bloqueado = FALSE 
                 WHERE id = $1 AND chat_bloqueado = TRUE`,
                [enc.conversacion_id]
            );
            console.log(`>>> 🔓 Chat desbloqueado para conv ${enc.conversacion_id} (ambos presentes)`);
        }

        // 4. Devolver estado
        res.json({
            encuentro_id: enc.id,
            estado: enc.estado,
            usuario1_verificado: usuariosVerificados.includes(enc.usuario1_id),
            usuario2_verificado: usuariosVerificados.includes(enc.usuario2_id),
            ambos_presentes: ambosPresentes,
            chat_desbloqueado: ambosPresentes,
        });
    } catch (error) {
        console.error('Error al consultar estado del encuentro:', error);
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/lugares-seguros', async (req, res) => {
    try {
        const { provincia, canton, distrito } = req.query;

        let query = 'SELECT * FROM lugares_seguros WHERE activo = TRUE';
        const params = [];
        let idx = 1;

        if (provincia) {
            query += ` AND provincia = $${idx}`;
            params.push(provincia);
            idx++;
        }
        if (canton) {
            query += ` AND canton = $${idx}`;
            params.push(canton);
            idx++;
        }
        if (distrito) {
            query += ` AND distrito = $${idx}`;
            params.push(distrito);
            idx++;
        }

        query += ' ORDER BY nombre ASC';

        const result = await pool.query(query, params);
        console.log(`>>> 🏛️ Lugares seguros encontrados: ${result.rows.length} (prov=${provincia || '-'}, cant=${canton || '-'}, dist=${distrito || '-'})`);
        res.json(result.rows);
    } catch (error) {
        console.error('Error al obtener lugares seguros:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================
// 🔥 DATOS DEL ENCUENTRO (foto del otro usuario)
// ============================================================
app.get('/api/encuentro/:id/datos', verificarTokenFirebase, async (req, res) => {
    try {
        const { id } = req.params;
        const usuario_id = req.usuarioAutenticado; // 🔥 del token, no del query

        const encResult = await pool.query(
            `SELECT * FROM encuentros_agendados WHERE id = $1`,
            [id]
        );

        if (encResult.rows.length === 0) {
            return res.status(404).json({ error: 'Encuentro no encontrado' });
        }

        const enc = encResult.rows[0];

        // 🔥 Verificar que el usuario autenticado sea PARTE del encuentro
        if (enc.usuario1_id !== usuario_id && enc.usuario2_id !== usuario_id) {
            console.log('>>> ❌ Intento de leer encuentro ajeno. User:', usuario_id, '| Encuentro:', id);
            return res.status(403).json({
                error: 'No autorizado para ver este encuentro',
                codigo: 'NO_ES_PARTE_DEL_ENCUENTRO'
            });
        }

        const otroUsuarioId = enc.usuario1_id === usuario_id
            ? enc.usuario2_id
            : enc.usuario1_id;

        // 🔥 Datos del otro usuario
        const userResult = await pool.query(
            `SELECT nombre, foto_perfil FROM usuarios WHERE uid = $1`,
            [otroUsuarioId]
        );

        // 🔥 Datos de la conversación y producto
        const convResult = await pool.query(
            `SELECT c.*, 
                    p.nombre AS producto_nombre,
                    p.imagen_url AS producto_imagen,
                    p.imagen_miniatura AS producto_imagen_miniatura,
                    p.precio AS producto_precio,
                    p.categoria AS producto_categoria,
                    p.descripcion AS producto_descripcion,
                    p.direccion AS producto_direccion,
                    p.imagen_destacada AS producto_imagen_destacada,
                    p.imagenes_reales AS producto_imagenes_reales
             FROM conversaciones_app c
             LEFT JOIN productos_app p ON c.producto_id = p.id
             WHERE c.id = $1`,
            [enc.conversacion_id]
        );

        const conv = convResult.rows[0] || {};

        res.json({
            encuentro_id: enc.id,
            otro_usuario_id: otroUsuarioId,
            otro_usuario_foto: userResult.rows[0]?.foto_perfil || '',
            otro_usuario_nombre: userResult.rows[0]?.nombre || 'Usuario',
            conversacion_id: enc.conversacion_id,
            producto_id: conv.producto_id || '',
            producto_nombre: conv.producto_nombre || 'Producto',
            producto_imagen: conv.producto_imagen || '',
            producto_imagen_miniatura: conv.producto_imagen_miniatura || '',
            producto_precio: conv.producto_precio?.toString() || '0',
            producto_categoria: conv.producto_categoria || '',
            producto_descripcion: conv.producto_descripcion || '',
            producto_direccion: conv.producto_direccion || '',
            producto_imagen_destacada: conv.producto_imagen_destacada || '',
            producto_imagenes_reales: conv.producto_imagenes_reales || '',
        });
    } catch (error) {
        console.error('Error al obtener datos del encuentro:', error);
        res.status(500).json({ error: error.message });
    }
});

server.listen(3000, '0.0.0.0', () => {
    console.log('Servidor corriendo en http://0.0.0.0:3000');
    console.log('>>> 🔌 WebSocket disponible en ws://0.0.0.0:3000/ws/chat');
});