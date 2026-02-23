// Mock API Base URL (Change to production URL)
const API_URL = 'http://127.0.0.1:5000/api/v1';
let currentTokenId = null; 
let currentCounterId = 'mock-counter-id'; // Assume selected from UI
let currentQueueId = 'mock-queue-id'; // Assume assigned to this counter

// Initialize Socket.io
const socket = io('http://127.0.0.1:5000', { transports: ['websocket'] });

socket.on('connect', () => {
    console.log('Connected to WebSocket server');
    // Join the queue room to listen to new tokens dropping in
    socket.emit('join_queue', { queueId: currentQueueId, userId: 'ADMIN' });
});

// Listen for updates pushed by the server
socket.on('queue_updated', (data) => {
    console.log('Live Queue Update:', data);
    if(data.action === 'NEW_TOKEN') {
        // A user just generated a token from the app
        refreshUpcomingTokens();
    }
});

// UI Elements
const btnCallNext = document.getElementById('btn-call-next');
const btnComplete = document.getElementById('btn-complete');
const btnNoShow = document.getElementById('btn-noshow');
const currentTokenDisp = document.getElementById('current-token');
const upcomingList = document.getElementById('upcoming-list');

// API Call Wrappers
async function callNextToken() {
    try {
        // Needs Bearer Token in real app
        const response = await fetch(`${API_URL}/counters/${currentCounterId}/call-next`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ queueId: currentQueueId })
        });
        
        if (!response.ok) throw new Error(await response.text());
        
        const token = await response.json();
        currentTokenId = token._id;
        currentTokenDisp.innerText = token.tokenNumber;
        
        refreshUpcomingTokens();
    } catch (error) {
        alert("Error calling next: " + error.message);
    }
}

async function markComplete() {
    if(!currentTokenId) return;
    try {
        await fetch(`${API_URL}/counters/${currentCounterId}/complete`, { method: 'POST' });
        currentTokenDisp.innerText = "--";
        currentTokenId = null;
    } catch (e) {
        console.error(e);
    }
}

async function markNoShow() {
    if(!currentTokenId) return;
    try {
        await fetch(`${API_URL}/counters/${currentCounterId}/no-show`, { method: 'POST' });
        currentTokenDisp.innerText = "--";
        currentTokenId = null;
    } catch (e) {
        console.error(e);
    }
}

// Mock function to refresh the right-hand sidebar queue list
function refreshUpcomingTokens() {
    // In production, GET /api/v1/queues/:id/waiting
    console.log('Refreshing upcoming tokens list...');
}

// Event Listeners
btnCallNext.addEventListener('click', callNextToken);
btnComplete.addEventListener('click', markComplete);
btnNoShow.addEventListener('click', markNoShow);
