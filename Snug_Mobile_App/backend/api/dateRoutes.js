import { pool } from "../config/databaseConfig.js";

//routes
export default function (app) {
    //get a date
    app.get("/dates/:id", async (req, res) => {
        const { id } = req.params;
        try {
            const fetchedDate = await pool.query("SELECT * FROM dates WHERE date_id = $1", [id]);
            if (fetchedDate.rows.length == 1) {
                res.json({ status: true, data: fetchedDate.rows[0] });
            } else {
                throw Error("No date found");
            }
        } catch (err) {
            console.error(err.message);
            res.json({ status: false, data: null });
        }
    });
    //create a date
    app.post("/dates", async (req, res) => {
        try {
            var data = JSON.parse(req.body['new_date']);
            const newDate = await pool.query("INSERT INTO dates (user_1, user_2, date_start, date_end, trusted_contacts, date_location, google_photo_reference, place_name, is_canceled, safe) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, false, false) RETURNING *", [data.user_1, data.user_2, data.date_start, data.date_end, data.trusted_contacts, data.date_location, data.google_photo_reference, data.place_name]);
            res.json({ status: true, data: newDate.rows[0]['date_id'] });
        } catch (err) {
            console.error(err.message);
            res.json({ status: false, data: null });
        }
    })
    app.put("/dates/cancel/:id", async (req, res) => {
        try {
            const { id } = req.params;
            const updatedDate = await pool.query("UPDATE dates SET is_canceled = true WHERE date_id = $1", [id]);
            if (updatedDate.rowCount == 1) {
                res.json({ status: true, data: null })
            } else {
                throw Error("Date not found");
            }
        } catch (err) {
            console.error(err.message);
            res.json({ status: false, data: null });
        }
    })

    app.put("/dates/safe/:id", async (req, res) => {
        try {
            const { id } = req.params;
            const safeDate = await pool.query("UPDATE dates SET safe = true WHERE date_id = $1", [id]);
            if(safeDate.rowCount ==1) {
                res.json({status: true, data: null})
            } else{
                throw Error("Date not found");
            }
        } catch (err) {
            console.error(err.message);
            res.json({status: false, data: null});
        }
    })
    
}