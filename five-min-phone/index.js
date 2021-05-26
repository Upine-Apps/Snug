
// STARTS WHATEVER IS INSIDE EVERY HOUR

import { pool } from "./config/databaseConfig.js";
// console.log(pool)
import dotenv from 'dotenv';
import aws from 'aws-sdk';

dotenv.config();
var AWS = aws;

var msg = 'Snug App here! Just checking in on you, are you okay? After 15 more minutes we\'ll send a message to all of your contacts. If you are safe, please go to your date on Snug and mark it as safe.';

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


setInterval(function () {

var currentDate = new Date(Date.now()-300000).setSeconds(0); //in case our program gets hung up or something and the seconds are more than 0
currentDate = new Date(currentDate).setMilliseconds(0); //same but with milliseconds
var currentDateISO = new Date(currentDate).toISOString() //real time UTC -5 minutes in ISO format

var testDateISO = new Date(Date.UTC(2020,4,5,12,50,0)-300000).toISOString(); //test date 5 minutes later then -5 minutes

console.log(currentDateISO); //comment out when testing
// console.log(testDateISO) //uncomment when testing

// var testTimeStart = '2020-05-05 12:45:00'; //we don't need this anymore bc I generated it but i'll leave it for reference

//query to get dates within last five minutes that are not canceled and haven't been marked safe
//gets user phone number as well
var selectQuery = `select users.phone_number, dates.date_end  from dates left join users on dates.user_1 = users.user_id where date_end = $1 and safe = false and is_canceled = false`; //make sure you're pulling dates that are not canceled and not marked safe as well

var dateData = [];
pool.query(selectQuery, async (err, res) => {
    try {

        const fetchedUser = await pool.query(selectQuery, [currentDateISO]); //change stuff in brackets to testDateISO when testing

        if (fetchedUser.rows.length) {
            dateData = fetchedUser.rows;

        } else {
            throw Error("No dates found");
        }
    } catch (err) {
        console.log(err);
        var curTime = new Date().toUTCString();
        console.error(`${curTime} -- ${err.message}`);
    }


    if (dateData.length > 0) {
        for (var i in dateData) {
            // console.log(dateData)  //uncomment this for testing

            //comment out everything else in this for loop for testing
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

}, 1000*60 //once a minute
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



