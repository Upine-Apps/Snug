
// STARTS WHATEVER IS INSIDE EVERY HOUR

import { pool } from "./config/databaseConfig.js";
import dotenv from 'dotenv';


import aws from 'aws-sdk';
setInterval(function () {
    dotenv.config();
   

function sendTextMessage(phone_number) {
    var params = {
        Message: msg,
        PhoneNumber: '+1' + phone_number,
        MessageAttributes: {
            'AWS.SNS.SMS.SenderID': {
                'DataType': 'String',
                'StringValue': 'Snug'
            }
        }
    };

    var publishTextPromise = new AWS.SNS({ apiVersion: '2010-03-31' }).publish(params).promise();
    return publishTextPromise;
}





var msg = 'Snug App here! Just checking in on you, are you okay? After 15 more minutes we\'ll send a message to all of your contacts. If you are safe, please go to your date on Snug and mark it as safe.';
var currentDate = new Date(new Date().toUTCString());
var currentDateConverted = `${currentDate.getFullYear()}-${currentDate.getUTCMonth()}-${currentDate.getUTCDay()} ${currentDate.getUTCHours()}:${currentDate.getUTCMinutes()}`;
var currentDateConvertedPlusFiveMin = `${currentDate.getFullYear()}-${currentDate.getUTCMonth()}-${currentDate.getUTCDay()} ${currentDate.getUTCHours()}:${currentDate.getUTCMinutes() - 5}`;

var testTimeStart = '2020-05-05 12:45:00';

//QUERY TO GET ALL DATES WITHIN AN HOUR
var selectQuery = `select users.phone_number, dates.date_end  from dates left join users on dates.user_1 = users.user_id where date_end = $1`; //make sure you're pulling dates that are not canceled and not marked safe as well

var dateData = [];
pool.query(selectQuery, async (err, res) => {
    try {
        // MAKE SURE TO CHANGE THE VARIABLES AT THE END
        const fetchedUser = await pool.query(selectQuery, [currentDateConvertedPlusFiveMin]);
        if (fetchedUser.rows.length) {
            dateData = fetchedUser.rows;
            console.log('------------')
            console.log(dateData);

        } else {
            throw Error("No dates found");
        }
    } catch (err) {
        console.log('didnt even connect to db');
        var curTime = new Date().toUTCString();
        console.error(`${curTime} -- ${err.message}`); //if this is a console error will it break the service?
    }


    // IF STATEMENT SO THAT WE CAN RUN SHIT AFTER THE QUERY IS FULLY DONE
    if (dateData.length > 0) {
        for (i in dateData) {
            var publishTextPromise = sendTextMessage(dateData[i].phone_number);
            publishTextPromise.then(
                function (data) {
                    console.info(`Sent text: ${data.MessageId}`);
                }).catch(
                    function (err) {
                        console.error(`Failed sending text to ${i.phone_number}. Error: ${err}`);
                    });
        }
    }
})

}, 1000
);



/*

WHEN WE ARE TESTING THIS, WE NEED TO MAKE SURE THAT IT IS ONLY PULLING LIKE 2 DATES
THIS WAY WE DON'T RUN UP THE CHARGES

*/











    // select phone_number from users where user_id = (select user_1 from dates where (date_end between '2021-05-20 13:09:00' and '2021-05-20 13:010:00') );

    // select users.phone_number, dates.trusted_contacts  from dates left join users on dates.user_1 = users.user_id where (date_end between '2021-05-20 13:09:00' and '2021-05-20 13:010:00');






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

//All users that receive the previous message gets sent to another function that will run every minute and check to see if it has been more than 20 min since the end of the date. 
//This is where we send the message to all contacts.
//---------------------------------------------------------------------//

//Probably make it efficient by checking to see if the list is full or not, if not full then we dont have to run the functions 



