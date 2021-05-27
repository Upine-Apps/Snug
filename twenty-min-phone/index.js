import { pool } from "./config/databaseConfig.js";
import dotenv from 'dotenv';
import aws from 'aws-sdk';
dotenv.config();
var AWS = aws;
var userMsg = `Snug App here! We haven\'t heard from you in a while. Just in case we are going to message your contacts so that they can check up on you. If you are safe please open your date on the Snug App and mark yourself safe.`;

setInterval(function () {
    
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

var currentDate = new Date(Date.now()-1200000).setSeconds(0); //in case our program gets hung up or something and the seconds are more than 0
currentDate = new Date(currentDate).setMilliseconds(0); //same but with milliseconds
var currentDateISO = new Date(currentDate).toISOString();
var testDateISO = new Date(Date.UTC(2021,4,27,1,21,0)-1200000).toISOString(); //test date 5 minutes later then -5 minutes

var selectQuery = `select users.first_name, users.last_name, users.phone_number, dates.trusted_contacts, dates.user_2, dates.date_location from dates left join users on dates.user_1 = users.user_id where date_end = $1 and safe = false and is_canceled = false`; //make sure you're pulling dates that are not canceled and not marked safe as well

var dateData = [];
pool.query(selectQuery, async (err, res) => {
    try {
        
        const fetchedUser = await pool.query(selectQuery, [currentDateISO]);
        if (fetchedUser.rows.length) {
            dateData = fetchedUser.rows;
            // console.log(dateData); //Comment out for testing

        } else {
            throw Error("No dates found");
        }
    } catch (err) {
        var curTime = new Date().toUTCString();
        console.error(`${curTime} -- ${err.message}`);
    }

    if (dateData.length > 0) {
        
        for (var i in dateData) {
            // Sending the user a message that their date is past twenty min
            var publishTextPromise = sendTextMessage(dateData[i].phone_number);
            publishTextPromise.then(
                function (data) {
                    console.info(`Sent text: ${data.MessageId}`);
                }).catch(
                    function (err) {
                        console.error(`Failed sending text to ${i.phone_number}. Error: ${err}`);
                    });
            // console.log('First msg');
            // console.log(dateData[i].phone_number);
           
            var secondSelectQuery = `select * from users where user_id = $1`;
            var secondUserInfo = [];
          
                try {
                    const secondFetchedUser = await pool.query(secondSelectQuery, [dateData[i].user_2]);
                    if(secondFetchedUser.rows.length) {
                        secondUserInfo = secondFetchedUser.rows;
                        console.log('User 2 info');
                        console.log(secondUserInfo);
                        if(secondUserInfo.length) {
                            var contactMsg = `Snug App here!. You are a trusted contact for ${dateData[i].first_name} ${dateData[i].last_name}. They have not responded back in a while, could you check up on ${dateData[i].first_name}? The last person seen with ${dateData[i].first_name} is ${secondUserInfo[0].first_name} ${secondUserInfo[0].last_name}. This is all the info we have about this person:
Name: ${secondUserInfo[0].first_name} ${secondUserInfo[0].last_name} 
Phone Number: ${secondUserInfo[0].phone_number} 
Sex: ${secondUserInfo[0].sex}
Race: ${secondUserInfo[0].race}
Eye Color: ${secondUserInfo[0].eye}
Hair Color: ${secondUserInfo[0].hair}
Height (in): ${secondUserInfo[0].height}
Their last known location is at 
(${dateData[i].date_location.x}, ${dateData[i].date_location.y}) (lat,long)`;
                            console.log(dateData[i]);
                            for(var y in dateData[i].trusted_contacts) {
                                
                                // console.log(dateData[i].trusted_contacts[y].phone_number);
                                // console.log('Second msg');
                                // console.log(dateData[i].trusted_contacts[y].phone_number);
                                // console.log(contactMsg);
                                var secondPublishTextPromise = sendTextMessageContact(dateData[i].trusted_contacts[y].phone_number, contactMsg);
                                secondPublishTextPromise.then(
                                    function (data) {
                                        console.info(`Sent text: ${dateData[i].trusted_contacts[y].phone_number}`);
                                    }
                                ).catch(
                                    function (err) {
                                        console.error(`Failed sending text to ${dateData[i].trusted_contacts[y].phone_number}. Error: ${err}`);
                                    }
                                )
        
                            }
                        }
                    } else {
                        throw Error("No second user found");
                    }
                } catch (err) {
                    var curTime = new Date().toUTCString();
                    console.error(`${curTime} -- ${err.message}`); 
                }
        }
    }
})
},60*1000
);

