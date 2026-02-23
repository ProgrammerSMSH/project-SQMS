const express = require('express');
const http = require('http');
const dotenv = require('dotenv');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { Server } = require('socket.io');
const connectDB = require('./config/db');
const { notFound, errorHandler } = require('./middlewares/errorMiddleware');
const authRoutes = require('./routes/authRoutes');
const queueRoutes = require('./routes/queueRoutes');
const tokenRoutes = require('./routes/tokenRoutes');
const counterRoutes = require('./routes/counterRoutes');
const { initSocket } = require('./utils/socketEvents');

dotenv.config();
connectDB();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

app.use(express.json());
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));

// Basic route for health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'SQMS Backend API is working' });
});

// Socket.io injection into request
app.use((req, res, next) => {
  req.io = io;
  next();
});

// Socket.IO logic
initSocket(io);

app.use('/api/v1', authRoutes); // Includes both user/auth & admin/auth
app.use('/api/v1/queues', queueRoutes);
app.use('/api/v1/tokens', tokenRoutes);
app.use('/api/v1/counters', counterRoutes);

app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
});
