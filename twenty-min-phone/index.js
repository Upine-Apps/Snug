// STARTS WHATEVER IS INSIDE EVERY HOUR
setInterval(function () {
    import { pool } from "./config/databaseConfig.js";
require('dotenv').config();


var AWS = require('aws-sdk');

function sendTextMessage(phone_number) {
    var params = {
        Message: userMsg,
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

function sendTextMessageContact(phone_number, msgContact) {
    var params = {
        Message: msgContact,
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





var userMsg = `Snug App here! We haven\'t heard from you in a while. Just in case we are going to message your contacts so that they can check up on you. If you are safe please open your date on the Snug App and mark yourself safe.`;
var currentDate = new Date(new Date().toUTCString());
var currentDateConverted = `${currentDate.getFullYear()}-${currentDate.getUTCMonth()}-${currentDate.getUTCDay()} ${currentDate.getUTCHours()}:${currentDate.getUTCMinutes()}`;
var currentDateConvertedTwentyMin = `${currentDate.getFullYear()}-${currentDate.getUTCMonth()}-${currentDate.getUTCDay()} ${currentDate.getUTCHours()}:${currentDate.getUTCMinutes() - 20}`;


//QUERY TO GET ALL DATES WITHIN AN HOUR
var selectQuery = `select * from dates left join users on dates.user_1 = users.user_id where date_end = $1`; //make sure you're pulling dates that are not canceled and not marked safe as well

var dateData = [];
pool.query(selectQuery, async (err, res) => {
    try {
        // MAKE SURE TO CHANGE THE VARIABLES AT THE END
        const fetchedUser = await pool.query(selectQuery, [currentDateConvertedTwentyMin]);
        if (fetchedUser.rows.length) {
            dateData = fetchedUser.rows;

        } else {
            throw Error("No dates found");
        }
    } catch (err) {
        var curTime = new Date().toUTCString();
        console.error(`${curTime} -- ${err.message}`); //if this is a console error will it break the service?
    }


    // IF STATEMENT SO THAT WE CAN RUN SHIT AFTER THE QUERY IS FULLY DONE
    if (dateData.length > 0) {
        
        for (i in dateData) {
            //Sending the user a message that their date is past twenty min
            var publishTextPromise = sendTextMessage(dateData[i].phone_number);
            publishTextPromise.then(
                function (data) {
                    console.info(`Sent text: ${data.MessageId}`);
                }).catch(
                    function (err) {
                        console.error(`Failed sending text to ${i.phone_number}. Error: ${err}`);
                    });
           
            var secondSelectQuery = `select * from users where user_id = $1`;
            pool.query(secondSelectQuery, async (err, res) => {
                try {
                    const secondFetchedUser = await pool.query(secondSelectQuery, [data[i].user_2]);
                    if(secondFetchedUser.rows.length) {
                        secondDateData = secondFetchedUser.rows;
                    } else {
                        throw Error("No second user found");
                    }
                } catch (err) {
                    var curTime = new Date().toUTCString();
                    console.error(`${curTime} -- ${err.message}`); 

                }

                if(secondDateData.length > 0) {
                    var contactMsg = `Snug App here!. You are a trusted contact for ${dateData[i].first_name} ${dateData[i].last_name}. They have not responded back in a while, could you check up on ${dateData[i].first_name}? The last person seen with ${dateData[i].first_name} is ${secondDateData[0].first_name} ${secondDateData[0].last_name}. 
                    This is all the info we have about this person:\n
                    Name: ${secondDateData[0].first_name} ${secondDateData[0].last_name} \n
                    Phone Number: ${secondDateData[0].phone_number} \n
                    Sex: ${secondDateData[0].sex}\n
                    Race: ${secondDateData[0].race}\n
                    Eye Color: ${secondDateData[0].eye}\n
                    Hair Color: ${secondDateData[0].hair}\n
                    Height (in): ${secondDateData[0].height}\n
                    Their last known location is at ${dateData[i].date_location} {lat,long}
                    `;

                    for(var y = 0; dateData[y].trusted_contacts.length; y+1) {
                        var secondPublishTextPromise = sendTextMessageContact(y.phone_number, contactMsg);
                        secondPublishTextPromise.then(
                            function (data) {
                                console.info(`Sent text: ${y.phone_number}`);
                            }
                        ).catch(
                            function (err) {
                                console.error(`Failed sending text to ${y.phone_number}. Error: ${err}`);
                            }
                        )

                    }
                }
            })
           
        }
    }
})

}, 60*1000
);

