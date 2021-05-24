
//STARTS WHATEVER IS INSIDE EVERY HOUR
// setInterval(function () {
//     console.log('this bitch running');
// }, 1*1000
// );


const {Pool, Client} = require('pg')
const pool = new Pool({
    user: "application",
    host: 'test-postgres.c6avwbngrz7p.us-east-1.rds.amazonaws.com',
    database: "TEST",
    password: "password",
    port: "5432"
    })

//GETTING THE CURRENT DATE AND THE THE CURRENT DATE PLUS AN HOUR
var currentDate = new Date(new Date().toUTCString());
var currentDateConverted = `${currentDate.getFullYear()}-${currentDate.getUTCMonth()}-${currentDate.getUTCDay()} ${currentDate.getUTCHours()}:${currentDate.getUTCMinutes()}`;
var currentDateConvertedPlusHour = `${currentDate.getFullYear()}-${currentDate.getUTCMonth()}-${currentDate.getUTCDay()} ${currentDate.getUTCHours()+1}:${currentDate.getUTCMinutes()}`;

var testTimeStart = '2020-05-05 11:00:00';
var testTimeEnd = '2020-05-05 12:00:00'

//QUERY TO GET ALL DATES WITHIN AN HOUR
var selectQuery = `SELECT * from dates where (date_start between $1 and $2)`;

var res;
res = { status: false, data: null };
    pool.query(selectQuery, async (err, res) => {
        try {
            // MAKE SURE TO CHANGE THE VARIABLES AT THE END
            const fetchedUser =  await pool.query(selectQuery,[testTimeStart,testTimeEnd]);
            if (fetchedUser.rows.length) {
                res = { status: true, data: fetchedUser.rows };   
            } else {
                throw Error("No user found");
            }
        } catch (err) {
            console.error(err.message);
           res = ({ status: false, data: null });
        }
       
        // IF STATEMENT SO THAT WE CAN RUN SHIT AFTER THE QUERY IS FULLY DONE
        if(res.data.length >0) {
        let userIdToSendMsg = [];
        let dateStartTime = [];
        for (let i in res.data) {
            userIdToSendMsg.push(res.data[i].user_1);
            dateStartTime.push(res.data[i].date_start);
            console.log(userIdToSendMsg);
            console.log(dateStartTime);
        }
        
          
        
        }
    })

 

    




    







// Logic for the messagging service 
//---------------------------------------------------------------------//
//Pull all dates in a certain hour ahead of the hour by like 15 mins. 
//For example dates starting at 2pm to 3pm should get pull at 1:45pm
//Send those dates a message saying that they have a incoming date and show the start date time. 

//Keep the list from the previous Data Base pull and have a function run every minute to check to see if the date has ended.
//This function will need to continously take in a list from the last function and add it to its previous list. 
//Meaning that the list should grow every hour.
//When date has ended send a message to the user asking to see if they are okay

//All users that receive the previous message gets sent to another function that will run every minute and check to see if it has been more than 5 min since the end of the date.

//All users that reveive the previous message gets sent to another function that will run every minute and check to see if it has been more than 15 min since the end of the date.

//All users that receive the previous message gets sent to another function that will run every minute and check to see if it has been more than 20 min since the end of the date. 
//This is where we send the message to all contacts.
//---------------------------------------------------------------------//

//Probably make it efficient by checking to see if the list is full or not, if not full then we dont have to run the functions 

