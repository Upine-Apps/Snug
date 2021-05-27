import { pool } from "../config/databaseConfig.js";

//routes
export default function (app) {
    //get a user
    app.get("/users/:id", async (req, res) => {
        const { id } = req.params;
        try {
            const fetchedUser = await pool.query("SELECT * FROM users WHERE user_id = $1", [id]);
            if (fetchedUser.rows.length == 1) {
                res.json({ status: true, data: fetchedUser.rows[0] });
            } else {
                throw Error("No user found");
            }
        } catch (err) {
            console.error(err.message);
            res.json({ status: false, data: null });
        }
    });
    
    //get registered user by phonenumber
    app.get("/users/registered/phonenumber/:phonenumber", async (req, res) => {
        const { phonenumber } = req.params;
        try{
            const fetchedUser = await pool.query("SELECT * FROM users WHERE phone_number = $1 AND temporary = false", [phonenumber]);
            if (fetchedUser.rows.length == 1){
                res.json({ status: true, data: fetchedUser.rows[0] });
            } else {
                throw Error("No user found");
            }
        } catch (err) {
            console.error(err.message);
            res.json({ status: false, data: null });
        }
    });

    //get reported user by phonenumber
    app.get("/users/reported/phonenumber/:phonenumber", async (req, res) => {
        const { phonenumber } = req.params;
        try{
            const fetchedUser = await pool.query("SELECT * FROM users WHERE phone_number = $1 AND temporary = true", [phonenumber]);
            if (fetchedUser.rows.length == 1){
                res.json({ status: true, data: fetchedUser.rows[0] });
            } else {
                throw Error("No user found");
            }
        } catch (err) {
            console.error(err.message);
            res.json({ status: false, data: null });
        }
    });
    
    //create a user
    app.post("/users", async (req, res) => {
        try {
            var data = req.body;
            console.log(req.body);
            console.log(Object.keys(req.body));
            console.log(Object.values(req.body));
            data.temp = Boolean.parse(data.temp);
            const newUser = await pool.query("INSERT INTO users (first_name, last_name, sex, phone_number, race, eye, hair, trusted_contacts, height, temporary, dob, street, city, state, zip) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15) RETURNING *", [data.first_name, data.last_name, data.sex, data.phone_number, data.race, data.eye, data.hair, data.trusted_contacts, data.height, data.temp, data.dob, data.street, data.city, data.state, data.zip]);
            res.json({ status: true, data: newUser.rows[0]['user_id'] });
        } catch (err) {
            console.error(err.message);
            res.json({ status: false, data: null });
        }
    })
    //update a user
    app.put("/users/:id", async (req, res) => {
        try {
            const { id } = req.params; //WHERE
            var data = req.body;
            console.log(req.body);
            console.log(Object.keys(req.body));
            console.log(Object.values(req.body));
            const updatedUser = await pool.query("UPDATE users SET eye = $2, hair = $3, height = $4, street = $5, city = $6, state = $7, zip = $8 WHERE user_id = $1", [id, data.eye, data.hair, data.height, data.street, data.city, data.state, data.zip]);
            if (updatedUser.rowCount == 1) {
                res.json({ status: true, data: null });
            } else {
                throw Error("Failed to update user");
            }
        } catch (err) {
            console.error(err.message);
            res.json({ status: false, data: null });

        }
    })

    app.put("/users/:id/trusted", async (req, res) => {
        try {
            var body = req.body['trusted_contacts'];
            var formattedBody = body.replace(/\\/g, "");
            const { id } = req.params;
            const updatedUser = await pool.query("UPDATE users SET trusted_contacts = $2 WHERE user_id = $1", [id, formattedBody]);
            if (updatedUser.rowCount == 1) {
                res.json({ status: true, message: 'Updated trusted contacts!' });
            } else {
                throw Error("Failed to update user");
            }
        } catch (err) {
            console.error(err.message);
            res.json({ status: false, data: null })
        }
    });

    app.get("/users/:id/dates", async (req, res) => {
        try {
            console.log(req.params);
            const { id } = req.params;
            const userDates = await pool.query("SELECT * FROM dates WHERE user_1 = $1 AND is_canceled != true AND safe != true", [id]);
            if (userDates.rows.length != 0) {
                res.json({ status: true, data: userDates.rows });
            } else {
                throw Error("Couldn't find dates");
            }
        } catch (err) {
            console.error(err.message);
            res.json({ status: false, data: null });
        }
    })
}