import  pg  from 'pg';
const { Pool } = pg;
const pool = new Pool({
    user: 'application',
    password: 'password',
    database: 'TEST',
    host: 'test-postgres.c6avwbngrz7p.us-east-1.rds.amazonaws.com',
    port: 5432
});

export { pool };