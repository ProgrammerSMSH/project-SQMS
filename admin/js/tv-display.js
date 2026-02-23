const API_URL = 'https://project-sqms.vercel.app/api/v1';

// We'll hardcode the queue ID for the TV display for now, 
// but in a perfect system this would be configurable via URL param or local storage.
const displayQueueId = '699cb8f138b27de96287b45f'; 

// State to track changes for animations
let previousServingTokens = {};

async function pollQueueStatus() {
    try {
        const response = await fetch(`${API_URL}/queues/${displayQueueId}/active-status`);
        if (!response.ok) return;
        const data = await res.json();
        
        renderActiveCounters(data.serving);
        renderWaitingList(data.waiting);

    } catch (e) {
        console.error("TV Display Polling Error:", e);
    }
}

function renderActiveCounters(servingData) {
    const grid = document.getElementById('active-counters-grid');
    if (!grid) return;
    grid.innerHTML = '';

    // Color palette for counters
    const colors = ['blue', 'green', 'red', 'purple', 'yellow'];

    servingData.forEach((serving, index) => {
        const color = colors[index % colors.length];
        const hasChanged = previousServingTokens[serving.counterName] !== serving.tokenNumber;
        const animClass = hasChanged ? 'called-animation' : '';
        
        if (hasChanged) {
            playSoundAlert();
            previousServingTokens[serving.counterName] = serving.tokenNumber;
        }

        const div = document.createElement('div');
        div.className = `bg-gray-800 rounded-2xl p-8 shadow-2xl border-l-8 border-${color}-500 flex flex-col items-center justify-center transform transition-transform ${animClass}`;
        div.innerHTML = `
            <p class="text-gray-400 text-3xl mb-4 font-light">${serving.counterName}</p>
            <div class="text-7xl lg:text-9xl font-black text-white tracking-tighter drop-shadow-lg">${serving.tokenNumber}</div>
        `;
        grid.appendChild(div);
    });

    if (servingData.length === 0) {
        grid.innerHTML = `<div class="col-span-2 text-center text-gray-500 text-2xl mt-20 font-light">Waiting for counters to open...</div>`;
    }
}

function renderWaitingList(waitingTokens) {
    const list = document.getElementById('waiting-list');
    if (!list) return;
    list.innerHTML = '';

    waitingTokens.forEach((token, index) => {
        const div = document.createElement('div');
        // Visually deprioritize items further down the list
        const opacity = index === 0 ? 'opacity-100 shadow-md transform scale-105' : 
                        index < 3 ? 'opacity-90' : 'opacity-60 text-gray-500';
        
        const nextBadge = index === 0 ? `<span class="text-lg bg-blue-600 text-white px-4 py-1 rounded-full font-bold shadow-sm animate-pulse">NEXT</span>` : '';
        
        div.className = `p-6 bg-gray-700/50 backdrop-blur-sm rounded-xl flex justify-between items-center border border-gray-600/50 transition-all ${opacity}`;
        div.innerHTML = `
            <div class="flex items-center gap-4">
               <span class="text-4xl font-bold font-mono tracking-tight">${token.tokenNumber}</span>
               ${token.priority !== 'NORMAL' ? `<span class="text-xs px-2 py-1 rounded bg-gray-800 text-gray-300 uppercase">${token.priority}</span>` : ''}
            </div>
            ${nextBadge}
        `;
        list.appendChild(div);
    });

    if (waitingTokens.length === 0) {
        list.innerHTML = `<div class="text-center text-gray-500 p-8">The queue is currently empty.</div>`;
    }
}

function playSoundAlert() {
    // In a real browser environment with user interaction, this would play a chime.
    console.log("DING DOOONG - New Token Called!");
}

// Start polling
pollQueueStatus();
setInterval(pollQueueStatus, 3000); // 3-second unified poll
