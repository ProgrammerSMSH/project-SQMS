const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const uri = process.env.MONGO_URI || "mongodb+srv://smshbd24_db_user:hGFDjEYfw5aZYzEe@cluster0.8ycgllq.mongodb.net/sqms_db?retryWrites=true&w=majority&appName=Cluster0";
    const conn = await mongoose.connect(uri);
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error(`Error connecting to MongoDB: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
