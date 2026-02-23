const initSocket = (io) => {
  io.on('connection', (socket) => {
    console.log('Socket connected:', socket.id);

    // Client requests to join a specific queue room to get live updates
    socket.on('join_queue', ({ queueId, userId }, callback) => {
      try {
        const roomName = `queue_${queueId}`;
        socket.join(roomName);
        console.log(`User ${userId} (Socket: ${socket.id}) joined room ${roomName}`);
        
        if(callback) callback({ status: 'success' });
      } catch (error) {
         console.error(error);
         if(callback) callback({ status: 'error', message: error.message });
      }
    });

    socket.on('leave_queue', ({ queueId }, callback) => {
        const roomName = `queue_${queueId}`;
        socket.leave(roomName);
        console.log(`Socket ${socket.id} left room ${roomName}`);
        if(callback) callback({ status: 'success' });
    });

    socket.on('disconnect', () => {
      console.log('Socket disconnected:', socket.id);
    });
  });
};

module.exports = { initSocket };
