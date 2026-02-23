const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const connectDB = require('./config/db');
const { notFound, errorHandler } = require('./middlewares/errorMiddleware');
const authRoutes = require('./routes/authRoutes');
const queueRoutes = require('./routes/queueRoutes');
const tokenRoutes = require('./routes/tokenRoutes');
const counterRoutes = require('./routes/counterRoutes');

dotenv.config();
connectDB().then(async () => {
  const User = require('./models/User');

  // One-time cleanup: Drop old phone index if it exists
  User.collection.dropIndex('phone_1').catch(() => {
    // Index doesn't exist, which is fine
  });

  // Seed Default Admin if none exists
  try {
    const adminExists = await User.findOne({ role: 'ADMIN' });
    if (!adminExists) {
      console.log('Seeding default admin user...');
      await User.create({
        name: 'System Admin',
        email: 'admin@sqms.com',
        password: 'admin123', // Will be hashed by pre-save hook
        role: 'ADMIN'
      });
      console.log('Default admin created: admin@sqms.com / admin123');
    }
  } catch (error) {
    console.error('Error seeding admin:', error);
  }
});

const app = express();

app.use(express.json());
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
// Basic route for health check
app.use(helmet());
app.use(morgan('dev'));

// Basic route for health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'SQMS Backend API is working' });
});

// Root route for browsers hits
app.get('/', (req, res) => {
  res.json({ 
     status: 'OK', 
     message: 'Welcome to SQMS API. Please use the Flutter App to communicate with /api/v1 endpoints.',
     documentation: 'REST API is active.'
  });
});

app.use('/api/v1/auth', authRoutes); // Unified auth prefix
app.use('/api/v1/queues', queueRoutes);
app.use('/api/v1/tokens', tokenRoutes);
app.use('/api/v1/counters', counterRoutes);

app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
});
