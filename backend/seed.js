require('dotenv').config();
const mongoose = require('mongoose');
const Location = require('./models/Location');
const Service = require('./models/Service');
const Counter = require('./models/Counter');

const seedData = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/sqms');
        
        // Clear existing data
        await Location.deleteMany({});
        await Service.deleteMany({});
        await Counter.deleteMany({});

        // 1. Create Location
        const location = await Location.create({
            name: 'University Central Library',
            type: 'Office',
            address: 'Main Campus, Sector 4',
            imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756ebafe3?auto=format&fit=crop&q=80&w=400'
        });

        // 2. Create Services
        const s1 = await Service.create({
            locationId: location._id,
            name: 'Financial Services',
            description: 'Tuition fees and scholarships',
            counterPrefix: 'F',
            avgServiceTime: 12
        });

        const s2 = await Service.create({
            locationId: location._id,
            name: 'Student Affairs',
            description: 'General inquiries and ID cards',
            counterPrefix: 'S',
            avgServiceTime: 8
        });

        // 3. Create Counters
        await Counter.create({
            serviceId: s1._id,
            counterNumber: 1,
            status: 'Active'
        });

        await Counter.create({
            serviceId: s2._id,
            counterNumber: 4,
            status: 'Active'
        });

        console.log('Database seeded successfully!');
        process.exit();
    } catch (error) {
        console.error('Seeding error:', error);
        process.exit(1);
    }
};

seedData();
