require('dotenv').config();
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const connectDB = require('./config/db');

// Initialize Express
const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

// Connect to Database
connectDB();

// Middleware
app.use(cors());
app.use(express.json());

// Socket.io Connection
io.on('connection', (socket) => {
    console.log('New client connected:', socket.id);
    
    socket.on('join_queue_room', (serviceId) => {
        socket.join(serviceId);
        console.log(`Socket ${socket.id} joined room: ${serviceId}`);
    });

    socket.on('disconnect', () => {
        console.log('Client disconnected');
    });
});

// Make io accessible to our routers
app.set('io', io);

// Basic Route
app.get('/', (req, res) => {
    res.send('SQMS Backend API is running...');
});

// Import Routes
const tokenRoutes = require('./routes/tokenRoutes');
const adminRoutes = require('./routes/adminRoutes');
app.use('/api/tokens', tokenRoutes);
app.use('/api/admin', adminRoutes);

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
