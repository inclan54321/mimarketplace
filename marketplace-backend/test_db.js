const { Pool } = require('pg');

const pool = new Pool({
    user: 'postgres',           // ← TU USUARIO
    host: 'localhost',
    database: 'railway',        // ← TU BASE DE DATOS
    password: 'Knives1997.1',  // ← TU CONTRASEÑA
    port: 5432,
});

pool.connect((err, client, release) => {
    if (err) {
        console.error('❌ ERROR DE CONEXIÓN:', err.message);
        return;
    }
    console.log('✅ CONEXIÓN EXITOSA A POSTGRESQL');
    release();
    pool.end();
});