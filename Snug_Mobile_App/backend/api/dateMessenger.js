// setInterval(function () {
//     console.log('this bitch running');
// }, 1*1000
// );


const pg = require('pg');
const R = require('ramda');

const cs = 'postgres://postgres:s$cret@localhost:5432/ydb';

const client = new pg.Client(cs);
client.connect();

client.query('SELECT 1 + 4').then(res => {

    const result = R.head(R.values(R.head(res.rows)));

    console.log(result);
}).finally(() => client.end());