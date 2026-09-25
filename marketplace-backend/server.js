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


const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());
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
            
            const solicitudResult = await pool.query(
                `SELECT * FROM mensajes_app 
                 WHERE conversacion_id = $1 
                 AND texto LIKE '%CALIFICACION_REQUEST%'`,
                [conversacionId]
            );

            console.log('>>> 🔥 solicitudResult.rows.length:', solicitudResult.rows.length);

            if (solicitudResult.rows.length === 0) {
                console.log('>>> 🔥 NO HAY SOLICITUD PREVIA - INSERTANDO...');
                
                const compradorId = conv.uid1 === conv.vendedor_id ? conv.uid2 : conv.uid1;
                console.log('>>> 🔥 compradorId (quien recibe el mensaje):', compradorId);
                
                const mensajeTexto = `||EL_COMPRADOR_YA_PUEDE_CALIFICARTE||`;
                
                const insertResult = await pool.query(
    `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
     VALUES ($1, $2, $3, $4, NOW()) RETURNING *`,
    [conversacionId, 'SYSTEM', mensajeTexto, '']  // ← CAMBIAR compradorId POR 'SYSTEM'
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
app.get('/api/productos/buscar', async (req, res) => {
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
             AND p.estado = 'activo'`,
            [`%${q}%`]
        );
        console.log('>>> ENCONTRADOS:', result.rows.length);
        res.json(result.rows);
    } catch (error) {
        console.error('ERROR:', error);
        res.status(500).json({ error: error.message });
    } 
});

app.get('/api/productos/:id', async (req, res) => {
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

app.get('/api/productos/categoria/:categoria', async (req, res) => {
    try {
        const { categoria } = req.params;
        const result = await pool.query(
            `SELECT p.*, u.nombre AS vendedor_nombre, u.foto_perfil AS vendedor_foto 
             FROM productos_app p
             LEFT JOIN usuarios u ON p.vendedor_id = u.uid
             WHERE p.categoria = $1 
               AND p.estado_moderacion = 'aprobado' 
               AND p.estado = 'activo'`,
            [categoria]
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/productos', async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT * FROM productos_app WHERE estado_moderacion = $1 AND estado = $2 ORDER BY id DESC',
            ['aprobado', 'activo']
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


app.get('/api/productos/vendedor/:vendedor_id', async (req, res) => {
    try {
        const { vendedor_id } = req.params;
        const result = await pool.query(
            `SELECT p.*, u.nombre AS vendedor_nombre, u.foto_perfil AS vendedor_foto
             FROM productos_app p
             LEFT JOIN usuarios u ON p.vendedor_id = u.uid
             WHERE p.vendedor_id = $1 AND p.estado_moderacion = 'aprobado'`,
            [vendedor_id]
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/productos', upload.fields([
  { name: 'imagen_destacada', maxCount: 1 },
  { name: 'imagen_normal', maxCount: 1 },
  { name: 'imagenes_reales[]', maxCount: 5 }
]), async (req, res) => {
    try {
        const { nombre, descripcion, precio, categoria, subcategoria, vendedor_id, direccion } = req.body;
        
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
        if (vendedor_id) {
            const userResult = await pool.query('SELECT nombre FROM usuarios WHERE uid = $1', [vendedor_id]);
            if (userResult.rows.length > 0) {
                vendedor_nombre = userResult.rows[0].nombre;
            }
        }

        // Obtener provincia desde las coordenadas
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
            } catch (e) {
                console.log('Error al obtener provincia:', e.message);
            }
        }

        // ===== GUARDAR CON ESTADO PENDIENTE =====
        const result = await pool.query(
            `INSERT INTO productos_app 
            (nombre, descripcion, precio, categoria, subcategoria, vendedor_id, direccion, imagen_url, vendedor_nombre, provincia, imagen_destacada, imagenes_reales, estado_moderacion, estado, fecha_expiracion, imagen_miniatura) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, 'pendiente', 'activo', NOW() + INTERVAL '30 days', $13) 
            RETURNING *`,
            [nombre, descripcion, precio, categoria, subcategoria, vendedor_id, direccion, imagen_principal_url || '', vendedor_nombre, provincia, imagen_destacada_url, imagenes_reales_json, imagen_miniatura_url || '']
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
app.post('/api/mensajes', upload.single('imagen'), async (req, res) => {
    try {
        console.log('>>> Archivo recibido:', req.file);
        const { conversacion_id, usuario_id, texto } = req.body;
        const imagen_url = req.file ? `/uploads/${req.file.filename}` : '';

        // 1. GUARDAR EL MENSAJE
        const result = await pool.query(
            `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
             VALUES ($1, $2, $3, $4, NOW()) RETURNING *`,
            [conversacion_id, usuario_id, texto, imagen_url]
        );

        // 2. VERIFICAR SI HAY QUE PEDIR CALIFICACIÓN
        await _verificarYPedirCalificacion(conversacion_id);

        // ============================================================
        // 🔥 ENVIAR NOTIFICACIÓN PUSH (DESPUÉS DE GUARDAR MENSAJE)
        // ============================================================
        try {
            // Obtener el receptor de la conversación
            const convResult = await pool.query(
                `SELECT usuario1_id, usuario2_id, producto_nombre 
                 FROM conversaciones 
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
                    await admin.messaging().send(mensajeFCM);
                    console.log('>>> 📨 Notificación push enviada a:', receptor_id);
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
app.post('/api/mensajes/audio', uploadAudio.single('audio'), async (req, res) => {
    try {
        const { conversacion_id, usuario_id, texto } = req.body;
        const audio_url = req.file ? `/uploads/audios/${req.file.filename}` : '';

        const result = await pool.query(
            `INSERT INTO mensajes_app (conversacion_id, usuario_id, texto, imagen, fecha) 
             VALUES ($1, $2, $3, $4, NOW()) RETURNING *`,
            [conversacion_id, usuario_id, texto || '🎤 Mensaje de voz', audio_url]
        );

        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('Error al guardar audio:', error);
        res.status(500).json({ error: error.message });
    }
});



app.get('/api/conversaciones/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;
        console.log('Buscando conversaciones para usuario:', usuario_id);
        const result = await pool.query(
            `SELECT c.*, 
             u1.nombre AS nombre1,
             u2.nombre AS nombre2,
             u1.foto_perfil AS foto_perfil1,
             u2.foto_perfil AS foto_perfil2,
             p.imagen_url AS producto_imagen,
             p.precio AS producto_precio,
             p.imagen_destacada AS producto_imagen_destacada,
             p.imagenes_reales AS producto_imagenes_reales,
             p.categoria AS productoCategoria,
             p.descripcion AS productoDescripcion,
             p.direccion AS productoDireccion,
             (SELECT texto FROM mensajes_app WHERE conversacion_id = c.id ORDER BY fecha DESC LIMIT 1) AS ultimo_mensaje
             FROM conversaciones_app c
             LEFT JOIN usuarios u1 ON c.usuario1_id = u1.uid
             LEFT JOIN usuarios u2 ON c.usuario2_id = u2.uid
             LEFT JOIN productos_app p ON c.producto_id = p.id
             WHERE c.usuario1_id = $1 OR c.usuario2_id = $1`,
            [usuario_id]
        );
         // 2. FILTRAR CONVERSACIONES CON BLOQUEADOS
        const conversaciones = result.rows;
        const conversacionesFiltradas = [];

        for (const conv of conversaciones) {
            const otroUsuarioId = conv.usuario1_id === usuario_id ? conv.usuario2_id : conv.usuario1_id;
            
            // Verificar si el otro usuario está bloqueado
            const bloqueoResult = await pool.query(
                'SELECT * FROM bloqueos WHERE usuario_bloquea = $1 AND usuario_bloqueado = $2',
                [usuario_id, otroUsuarioId]
            );

            // Si no está bloqueado, incluir la conversación
            if (bloqueoResult.rows.length === 0) {
                conversacionesFiltradas.push(conv);
            }
        }
        console.log('Conversaciones encontradas:', result.rows);
        res.json(result.rows);
    } catch (error) {
        console.error('Error al obtener conversaciones:', error);
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/conversaciones', async (req, res) => {
    try {
        console.log('>>> 1. POST /api/conversaciones recibido');
        const { usuario1_id, usuario2_id, producto_nombre, producto_id, producto_imagen } = req.body;
        console.log('>>> 2. producto_imagen recibido:', producto_imagen);
        console.log('>>> 3. producto_id recibido:', producto_id);
        
        // 🔥 OBTENER EL VENDEDOR REAL DEL PRODUCTO 🔥
        let vendedor_id = null;
        if (producto_id) {
            const productResult = await pool.query(
                'SELECT vendedor_id FROM productos_app WHERE id = $1',
                [producto_id]
            );
            if (productResult.rows.length > 0) {
                vendedor_id = productResult.rows[0].vendedor_id;
                console.log('>>> 4. vendedor_id del producto ENCONTRADO:', vendedor_id);
            } else {
                console.log('>>> 4. PRODUCTO NO ENCONTRADO para ID:', producto_id);
            }
        }
        
        // 🔥 GUARDAR LA CONVERSACIÓN CON EL VENDEDOR_ID 🔥
        const result = await pool.query(
            `INSERT INTO conversaciones_app (usuario1_id, usuario2_id, fecha_creacion, producto_nombre, producto_id, producto_imagen, vendedor_id) 
             VALUES ($1, $2, NOW(), $3, $4, $5, $6) RETURNING *`,
            [usuario1_id, usuario2_id, producto_nombre || '', producto_id, producto_imagen || '', vendedor_id]
        );
        console.log('>>> 5. CONVERSACIÓN CREADA CON vendedor_id:', result.rows[0].vendedor_id);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('>>> 6. ERROR:', error);
        res.status(500).json({ error: error.message });
    }
});
app.post('/api/favoritos', async (req, res) => {
    try {
        const { usuario_id, producto_id } = req.body;
        
        console.log('>>> AGREGANDO FAVORITO - producto:', producto_id);
        
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

app.delete('/api/favoritos', async (req, res) => {
    try {
        const { usuario_id, producto_id } = req.body;
        
        console.log('>>> ELIMINANDO FAVORITO - producto:', producto_id);
        
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

app.get('/api/favoritos/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;
        console.log('🔥 Buscando favoritos para usuario:', usuario_id);
        
        const result = await pool.query(
            `SELECT 
                p.*, 
                u.nombre AS vendedor_nombre, 
                u.foto_perfil AS vendedor_foto
             FROM productos_app p
             JOIN productos_favoritos f ON p.id::text = f.producto_id
             LEFT JOIN usuarios u ON p.vendedor_id = u.uid
             WHERE f.usuario_id = $1
               AND p.estado_moderacion = 'aprobado'`,
            [usuario_id]
        );
        
        console.log('✅ Productos favoritos encontrados:', result.rows.length);
        res.json(result.rows);
    } catch (error) {
        console.error('❌ Error al obtener favoritos:', error);
        res.status(500).json({ error: error.message });
    }
});
// RUTA PARA SUBIR FOTO DE PERFIL
app.post('/api/perfil/foto', upload.single('foto'), async (req, res) => {
    console.log('Body:', req.body);
    console.log('File:', req.file);
    console.log('UID:', req.body.uid);

    try {
        const { uid } = req.body;
        const fotoUrl = req.file ? `/uploads/${req.file.filename}` : '';

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
app.get('/api/geocode/:lat/:lng', async (req, res) => {
    try {
        const { lat, lng } = req.params;
        const response = await axios.get(
            `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json&addressdetails=1&zoom=18`,
            {
                headers: {
                    'User-Agent': 'MiMarketplaceCR/1.0 (https://mimarketplace.com)'
                }
            }
        );
        const address = response.data.address;
        console.log('Address completo:', address);
        
        const provincia = address.state || address.region || address.province || '';
        const canton = address.county || address.city || address.town || address.municipality || '';
        
        res.json({ provincia, canton });
    } catch (error) {
        console.error('Error al geocodificar:', error.response?.data || error.message);
        res.status(500).json({ error: error.message });
    }
});
app.get('/api/mensajes/:conversacion_id', async (req, res) => {
    try {
        const { conversacion_id } = req.params;
        const usuario_id = req.query.usuario_id; // 🔥 USUARIO QUE ESTÁ VIENDO EL CHAT

        if (!usuario_id) {
            return res.status(400).json({ error: 'usuario_id es requerido' });
        }

        // 1. OBTENER LA CONVERSACIÓN
        const convResult = await pool.query(
            'SELECT * FROM conversaciones_app WHERE id = $1',
            [conversacion_id]
        );
        if (convResult.rows.length === 0) {
            return res.status(404).json({ error: 'Conversación no encontrada' });
        }

        const conv = convResult.rows[0];
        
        // 2. DETERMINAR QUIÉN ES EL OTRO USUARIO
        const otroUsuarioId = conv.usuario1_id === usuario_id ? conv.usuario2_id : conv.usuario1_id;

        // 3. VERIFICAR SI EL OTRO USUARIO ESTÁ BLOQUEADO
        const bloqueoResult = await pool.query(
            'SELECT * FROM bloqueos WHERE usuario_bloquea = $1 AND usuario_bloqueado = $2',
            [usuario_id, otroUsuarioId]
        );

        // 4. OBTENER MENSAJES
        let query = 'SELECT * FROM mensajes_app WHERE conversacion_id = $1';
        const params = [conversacion_id];

        // 5. SI ESTÁ BLOQUEADO, FILTRAR MENSAJES DEL BLOQUEADO
        if (bloqueoResult.rows.length > 0) {
            // El usuario bloqueó al otro, no ver sus mensajes
            query += ' AND usuario_id != $2';
            params.push(otroUsuarioId);
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
app.post('/api/usuarios', async (req, res) => {
    try {
        const { uid, email, nombre, telefono, acepta_recoleccion } = req.body;
        console.log('>>> Creando usuario:', { uid, email, nombre, telefono, acepta_recoleccion });
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

// RUTA PARA ELIMINAR CONVERSACIÓN
app.delete('/api/conversaciones/:id', async (req, res) => {
    try {
        const { id } = req.params;
        console.log('>>> Eliminando conversación ID:', id);
        
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


// ===== RUTA PARA OBTENER ALERTAS =====
app.get('/api/alertas/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;
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

// ===== RUTA PARA MARCAR ALERTA COMO LEÍDA =====
app.put('/api/alertas/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('UPDATE alertas SET leida = TRUE WHERE id = $1', [id]);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ===== RUTA PARA ELIMINAR TODAS LAS ALERTAS DE UN USUARIO =====
app.delete('/api/alertas/limpiar/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;
        await pool.query('DELETE FROM alertas WHERE usuario_id = $1', [usuario_id]);
        res.json({ success: true, mensaje: 'Todas las alertas eliminadas' });
    } catch (error) {
        console.error('Error al limpiar alertas:', error);
        res.status(500).json({ error: error.message });
    }
});
// ===== RUTA PARA GUARDAR BÚSQUEDAS =====
app.post('/api/busquedas-app', async (req, res) => {
    try {
        const { usuario_id, termino } = req.body;
        
        if (!usuario_id || !termino || termino.length < 4) {
            return res.status(400).json({ error: 'Datos inválidos' });
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
app.post('/api/bloquear', async (req, res) => {
    try {
        const { usuario_bloquea, usuario_bloqueado } = req.body;
        
        if (!usuario_bloquea || !usuario_bloqueado) {
            return res.status(400).json({ error: 'Faltan datos' });
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

app.delete('/api/bloquear', async (req, res) => {
    try {
        const { usuario_bloquea, usuario_bloqueado } = req.body;
        
        if (!usuario_bloquea || !usuario_bloqueado) {
            return res.status(400).json({ error: 'Faltan datos' });
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
app.get('/api/bloquear/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;
        
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
app.post('/api/calificaciones/from-chat', async (req, res) => {
    try {
        const { conversacion_id, calificador_id, calificado_id, puntuacion, comentario } = req.body;

        if (!conversacion_id || !calificador_id || !calificado_id || !puntuacion) {
            return res.status(400).json({ error: 'Faltan datos' });
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
app.delete('/api/productos/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { vendedor_id } = req.body;
        
        console.log('>>> ELIMINAR PRODUCTO ID:', id);
        console.log('>>> VENDEDOR_ID:', vendedor_id);

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
// ===== OBTENER AGENDA POR USUARIO =====
app.get('/api/agenda/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;
        const result = await pool.query(
            'SELECT * FROM agenda WHERE usuario_id = $1 ORDER BY fecha_guardado DESC',
            [usuario_id]
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/agenda', async (req, res) => {
    try {
        console.log('>>> GUARDANDO EN AGENDA:', req.body);
        
        const { usuario_id, otro_usuario, producto_nombre, ultimo_mensaje, producto_imagen, conversacion_id } = req.body;
        
        console.log('>>> usuario_id:', usuario_id);
        console.log('>>> conversacion_id:', conversacion_id);
        
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
                 SET otro_usuario = $1, producto_nombre = $2, ultimo_mensaje = $3, producto_imagen = $4, fecha_guardado = NOW()
                 WHERE usuario_id = $5 AND conversacion_id = $6
                 RETURNING *`,
                [otro_usuario, producto_nombre, ultimo_mensaje, producto_imagen, usuario_id, conversacion_id]
            );
            console.log('>>> ACTUALIZADO:', result.rows[0]);
            res.json(result.rows[0]);
        } else {
            // Insertar
            console.log('>>> INSERTANDO NUEVO...');
            const result = await pool.query(
                `INSERT INTO agenda (usuario_id, otro_usuario, producto_nombre, ultimo_mensaje, producto_imagen, conversacion_id)
                 VALUES ($1, $2, $3, $4, $5, $6)
                 RETURNING *`,
                [usuario_id, otro_usuario, producto_nombre, ultimo_mensaje, producto_imagen, conversacion_id]
            );
            console.log('>>> INSERTADO:', result.rows[0]);
            res.status(201).json(result.rows[0]);
        }
    } catch (error) {
        console.error('>>> ERROR EN AGENDA:', error);
        res.status(500).json({ error: error.message });
    }
});

// ===== ELIMINAR DE AGENDA =====
app.delete('/api/agenda/:id', async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('DELETE FROM agenda WHERE id = $1', [id]);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
// ===== REGISTRAR VISTA DE PRODUCTO =====
app.post('/api/productos/:id/vista', async (req, res) => {
    try {
        const { id } = req.params;
        const { usuario_id } = req.body;
        const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;

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
app.post('/api/agenda/guardar-todas', async (req, res) => {
    try {
        const { usuario_id, conversaciones } = req.body;

        console.log('>>> Agenda - Recibidas:', conversaciones.length);

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
app.get('/api/agenda/:usuario_id', async (req, res) => {
    try {
        const { usuario_id } = req.params;

        console.log('>>> Agenda - OBTENIENDO para usuario:', usuario_id);

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
app.delete('/api/agenda/:id', async (req, res) => {
    try {
        const { id } = req.params;

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
app.put('/api/productos/:id', upload.single('imagen'), async (req, res) => {
    try {
        const { id } = req.params;
        const { nombre, descripcion, precio, categoria, subcategoria, direccion } = req.body;
        
        console.log('>>> EDITANDO PRODUCTO ID:', id);
        console.log('>>> NOMBRE:', nombre);
        console.log('>>> IMAGEN RECIBIDA:', req.file ? 'SÍ' : 'NO');
        
        // 1. OBTENER EL PRODUCTO ACTUAL
        const productoActual = await pool.query(
            'SELECT * FROM productos_app WHERE id = $1',
            [id]
        );
        
        if (productoActual.rows.length === 0) {
            return res.status(404).json({ error: 'Producto no encontrado' });
        }
        
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
app.post('/api/denuncias', async (req, res) => {
    try {
        const { denunciante_id, denunciado_id, producto_id, motivo } = req.body;
        
        if (!denunciante_id || !denunciado_id || !producto_id) {
            return res.status(400).json({ error: 'Faltan datos' });
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
app.post('/api/revisar-imagen-destacada', upload.single('imagen'), async (req, res) => {
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

        // Obtener provincia desde coordenadas
        let provincia = '';
        if (direccion && direccion.includes(',')) {
            try {
                const latLng = direccion.split(',');
                const lat = latLng[0].replace('Lat: ', '').trim();
                const lng = latLng[1].replace('Lng: ', '').trim();
                const geoResponse = await axios.get(
                    `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json&addressdetails=1&zoom=10`,
                    { headers: { 'User-Agent': 'MiMarketplaceCR/1.0' } }
                );
                provincia = geoResponse.data.address?.state || geoResponse.data.address?.region || '';
            } catch (e) {
                console.log('Error al obtener provincia:', e.message);
            }
        }

        const result = await pool.query(
            `INSERT INTO productos_app 
            (nombre, descripcion, precio, categoria, subcategoria, vendedor_id, direccion, 
             imagen_url, vendedor_nombre, provincia, imagen_destacada, imagenes_reales, 
             estado_moderacion, estado_ia_destacada, destacada_publicada, fecha_expiracion) 
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, 'pendiente', 'pendiente', false, NOW() + INTERVAL '30 days') 
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
// ===== ANALIZAR CHAT CON IA (DEEPSEEK) =====
app.post('/api/analizar-chat', async (req, res) => {
    try {
        const { mensaje, usuario_id, conversacion_id } = req.body;

        if (!mensaje || mensaje.length < 3) {
            return res.json({ 
                estado: 'neutral', 
                analisis: 'Mensaje muy corto para analizar' 
            });
        }

        const DEEPSEEK_API_KEY = process.env.DEEPSEEK_API_KEY;  // ✅ BIEN
        const url = 'https://api.deepseek.com/v1/chat/completions';

        const prompt = `Analiza este mensaje de un chat de marketplace y determina si hay señales de:

1. ESTAFA o FRAUDE (precios muy bajos, urgencia, pedir dinero fuera de la plataforma)
2. MALENTENDIDOS (información confusa, promesas poco claras)
3. INFORMACIÓN OMITIDA (no responde preguntas, evade temas)
4. COMPORTAMIENTO SOSPECHOSO (insiste en algo, presión)

Mensaje: "${mensaje}"

Responde ÚNICAMENTE con un JSON válido:
{"estado":"good","analisis":"explicación breve en español"}`;

        const response = await axios.post(url, {
            model: 'deepseek-chat',
            messages: [
                { role: 'system', content: 'Eres un asistente que analiza mensajes de chat para detectar fraudes y malentendidos. Responde SOLO con JSON.' },
                { role: 'user', content: prompt }
            ],
            temperature: 0.1,
            max_tokens: 80,
        }, {
            headers: {
                'Authorization': `Bearer ${DEEPSEEK_API_KEY}`,
                'Content-Type': 'application/json'
            },
            timeout: 10000
        });

        // 🔥 MOSTRAR TOKENS GASTADOS
        const usage = response.data.usage;
        console.log('>>> 📊 TOKENS GASTADOS:');
        console.log('>>>   - Prompt tokens: ' + (usage?.prompt_tokens || 'N/A'));
        console.log('>>>   - Completion tokens: ' + (usage?.completion_tokens || 'N/A'));
        console.log('>>>   - Total tokens: ' + (usage?.total_tokens || 'N/A'));

        const text = response.data.choices?.[0]?.message?.content || '';
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        
        if (jsonMatch) {
            try {
                const resultado = JSON.parse(jsonMatch[0]);
                return res.json({
                    estado: resultado.estado || 'neutral',
                    analisis: resultado.analisis || 'Análisis completado'
                });
            } catch (e) {
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
app.post('/api/productos/renovar/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { usuario_id } = req.body;

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
// 🔥 OBTENER DATOS DE UN USUARIO
// ============================================================
app.get('/api/usuarios/:uid', async (req, res) => {
    try {
        const { uid } = req.params;
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
app.put('/api/usuarios/:uid', async (req, res) => {
    try {
        const { uid } = req.params;
        const { nombre, telefono, acepta_recoleccion } = req.body;
        
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
app.post('/api/calificaciones', async (req, res) => {
    try {
        const { calificado_id, calificador_id, producto_id, puntuacion, comentario } = req.body;
        
        console.log('>>> 🔥 ====== GUARDANDO CALIFICACIÓN ======');
        console.log('>>> calificado_id (vendedor):', calificado_id);
        console.log('>>> calificador_id (comprador):', calificador_id);
        console.log('>>> producto_id:', producto_id);
        console.log('>>> puntuacion:', puntuacion);
        console.log('>>> comentario:', comentario);

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
app.post('/api/soporte/enviar', async (req, res) => {
    try {
        const { usuario_id, asunto, mensaje } = req.body;

        if (!usuario_id || !mensaje || mensaje.trim().isEmpty) {
            return res.status(400).json({ error: 'usuario_id y mensaje obligatorios' });
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
app.listen(3000, '0.0.0.0', () => {
    console.log('Servidor corriendo en http://0.0.0.0:3000');
});