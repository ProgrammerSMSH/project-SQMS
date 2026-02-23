const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');
const Queue = require('./models/Queue');
const Counter = require('./models/Counter');

dotenv.config();

const seedData = async () => {
  try {
    const uri = process.env.MONGO_URI || "mongodb+srv://smshbd24_db_user:hGFDjEYfw5aZYzEe@cluster0.8ycgllq.mongodb.net/sqms_db?retryWrites=true&w=majority&appName=Cluster0";
    await mongoose.connect(uri);
    console.log('Connected to MongoDB for seeding...');

    // 1. Seed Admin User
    const adminPhone = '01700000000';
    let admin = await User.findOne({ phone: adminPhone });
    if (!admin) {
      admin = await User.create({
        name: 'Main Admin',
        phone: adminPhone,
        role: 'ADMIN',
      });
      console.log('Admin user created.');
    } else {
      console.log('Admin user already exists.');
    }

    // 2. Seed Queue
    const queueCode = 'GN';
    let queue = await Queue.findOne({ code: queueCode });
    if (!queue) {
      queue = await Queue.create({
        name: 'General Checkup',
        code: queueCode,
        avgWaitTimePerToken: 5,
      });
      console.log('General Queue created.');
    } else {
      console.log('General Queue already exists.');
    }

    // 3. Seed Counter
    const counterName = 'Counter 1';
    let counter = await Counter.findOne({ name: counterName });
    if (!counter) {
      counter = await Counter.create({
        name: counterName,
        status: 'ACTIVE',
        assignedAdminId: admin._id,
      });
      console.log('Counter 1 created.');
    } else {
      console.log('Counter 1 already exists.');
    }

    console.log('Seeding completed successfully!');
    console.log('-----------------------------------');
    console.log('USE THESE IDs IN FRONTEND CONFIG:');
    console.log(`Queue ID: ${queue._id}`);
    console.log(`Counter ID: ${counter._id}`);
    console.log('-----------------------------------');

    process.exit();
  } catch (error) {
    console.error(`Error seeding data: ${error.message}`);
    process.exit(1);
  }
};

seedData();
