import express from 'express';
import userRoutes from './api/userRoutes.js';
import dateRoutes from './api/dateRoutes.js';
import CognitoExpress from 'cognito-express';

const app = express();//, authenticatedRoute = express.Router();
app.use(express.json());
app.use(express.urlencoded({extended: false}));
// app.use("/api", authenticatedRoute);

const cognitoExpress = new CognitoExpress({
    region: "us-east-2",
    cognitoUserPoolId: "us-east-2_rweyLTmso",
    tokenUse: "access",
    tokenExpiration: 3600000
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

