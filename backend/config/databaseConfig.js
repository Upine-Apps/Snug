import  pg  from 'pg';
const { Pool } = pg;
require('dotenv').config();
const pool = new Pool({
    user: process.env.POSTGRES_USERNAME,
    password: process.env.POSTGRES_PASSWORD,
    database: process.env.POSTGRES_DATABASE,
    host: process.env.POSTGRES_HOST,
    port: process.env.POSTGRES_PORT
});

export { pool };