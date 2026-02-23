const socket = io('http://localhost:5000', { transports: ['websocket'] });

// TV Display is listening to the General Checkup Queue ID
const displayQueueId = '699cb8f138b27de96287b45f';

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

async function refreshWaitingList() {
    try {
        const response = await fetch(`http://localhost:5000/api/v1/queues/${displayQueueId}/waiting`);
        if (!response.ok) throw new Error("Failed to fetch waiting list");
        
        const tokens = await response.json();
        const waitingListEl = document.getElementById('waiting-tokens-list');
        if (!waitingListEl) return;

        waitingListEl.innerHTML = '';
        tokens.forEach(token => {
            const div = document.createElement('div');
            div.className = 'text-3xl font-bold p-4 bg-white rounded-lg shadow-sm border-l-8 border-blue-500 flex justify-between';
            div.innerHTML = `<span>${token.tokenNumber}</span> <span class="text-sm text-gray-400 font-normal self-center">${token.priority}</span>`;
            waitingListEl.appendChild(div);
        });
    } catch (e) {
        console.error(e);
    }
}

// Initial load
refreshWaitingList();

function playSoundAlert() {
    // Play a gentle ding chime when a new patient is called
    console.log("DING DOOONG");
    // new Audio('bell.mp3').play();
}
