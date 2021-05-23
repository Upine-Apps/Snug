import express from 'express';
import userRoutes from './api/userRoutes.js';
import dateRoutes from './api/dateRoutes.js';


const app = express();
app.use(express.json());
app.use(express.urlencoded({extended: false}));

const port = process.env.PORT || 3000;
userRoutes(app);
dateRoutes(app);

app.get('/', (request, response) => {
    response.json({status: true, data: 'Backend :)'});
})
app.listen(port, () => {
    console.log("Server is listening on port " + port);
});

