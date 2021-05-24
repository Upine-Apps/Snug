import express from 'express';
import userRoutes from './api/userRoutes.js';
import dateRoutes from './api/dateRoutes.js';
import CognitoExpress from 'cognito-express';
import dotenv from 'dotenv';
dotenv.config();
const app = express();//, authenticatedRoute = express.Router();
app.use(express.json());
app.use(express.urlencoded({extended: false}));

// app.use("/api", authenticatedRoute);

const cognitoExpress = new CognitoExpress({
    region: process.env.AWS_REGION,
    cognitoUserPoolId: process.env.AWS_COGNITO_POOL_ID,
    tokenUse: "access",
    tokenExpiration: 3600000 //one hour
});

const port = process.env.PORT || 3000;

app.use((req,res,next) => {
    let accessTokenFromClient = req.headers.accesstoken;
    if (!accessTokenFromClient) return res.status(401).send("Access token missing");

    cognitoExpress.validate(accessTokenFromClient, (err, response) => {
        if(err) return res.status(401).send({status: false, data: err});

        res.locals.user = response;
        next();
    })
})
 
userRoutes(app);
dateRoutes(app);

app.get('/', (request, response) => { // make this into a healthcheck later by making separate router for authenticated requests. LOOK AT NPM DOCUMENTATION
    response.json({status: true, data: 'Backend :)'});
})
app.listen(port, () => {
    console.log("Server is listening on port " + port);
});

