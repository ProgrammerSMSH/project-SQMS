const socket = io('http://127.0.0.1:5000', { transports: ['websocket'] });

// Assume this display is listening to a specific Queue ID
const displayQueueId = 'mock-queue-id';

socket.on('connect', () => {
    console.log('TV Display connected to WebSocket server');
    socket.emit('join_queue', { queueId: displayQueueId, userId: 'TV_DISPLAY' });
});

// Listen for updates pushed by the server
socket.on('queue_updated', (data) => {
    console.log('TV Display Update:', data);
    
    if (data.action === 'CALLED_NEXT') {
        // data.currentTokenServing, data.counterName
        updateActiveCounterGrid(data.counterName, data.currentTokenServing);
        playSoundAlert();
    } else if (data.action === 'NEW_TOKEN') {
        refreshWaitingList();
    }
});

function updateActiveCounterGrid(counterName, tokenNumber) {
    // In production, find the specific Counter box by ID and update it.
    // Here we'll just demonstrate the animation trigger.
    
    const countersGrid = document.getElementById('active-counters-grid');
    // ... Find and update text ...
    
    // Add pulsing highlight animation
    const targetCard = countersGrid.children[0]; 
    targetCard.classList.remove('called-animation');
    void targetCard.offsetWidth; // Trigger reflow
    targetCard.classList.add('called-animation');
}

function refreshWaitingList() {
    // GET waiting list and render
}

function playSoundAlert() {
    // Play a gentle ding chime when a new patient is called
    console.log("DING DOOONG");
    // new Audio('bell.mp3').play();
}
