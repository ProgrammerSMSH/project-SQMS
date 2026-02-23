const connectDB = require('./config/db');
const Location = require('./models/Location');
const Service = require('./models/Service');
require('dotenv').config();

connectDB().then(async () => {
    try {
        const locations = await Location.find();
        console.log("Locations in DB:", locations);
        
        const services = await Service.find();
        console.log("Services in DB:", services);
    } catch(err) {
        console.error(err);
    }
    process.exit();
});
