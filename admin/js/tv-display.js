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
        const data = await response.json();
        
        renderActiveCounters(data.serving);
        renderWaitingList(data.waiting);

    } catch (e) {
        console.error("TV Display Polling Error:", e);
    }
}

async function pollAnnouncements() {
    try {
        const res = await fetch(`${API_URL}/announcements/active`);
        if (!res.ok) return;
        const announcements = await res.json();
        
        const tickerContainer = document.getElementById('ticker-container');
        const ticker = document.getElementById('announcement-ticker');
        
        if (announcements.length > 0) {
            const combinedMessage = announcements.map(a => a.message).join('    &nbsp;&nbsp;•&nbsp;&nbsp;    ');
            ticker.innerHTML = combinedMessage;
            tickerContainer.classList.remove('hidden');
        } else {
            tickerContainer.classList.add('hidden');
        }
    } catch (e) {
        console.error("Announcement Polling Error:", e);
    }
}

function renderActiveCounters(servingData) {
    const grid = document.getElementById('active-counters-grid');
    if (!grid) return;
    grid.innerHTML = '';
    servingData.forEach((serving, index) => {
        const hasChanged = previousServingTokens[serving.counterName] !== serving.tokenNumber;
        const animClass = hasChanged ? 'call-flash' : '';
        
        if (hasChanged) {
            playSoundAlert();
            previousServingTokens[serving.counterName] = serving.tokenNumber;
        }

        const div = document.createElement('div');
        div.className = `glass p-12 flex flex-col items-center justify-center relative overflow-hidden transition-all duration-700 ${animClass}`;
        div.innerHTML = `
            <div class="absolute inset-0 bg-blue-500/5 -z-10"></div>
            <p class="font-tomorrow text-xl text-white/30 tracking-[10px] uppercase mb-4">${serving.counterName}</p>
            <div class="text-[120px] font-tomorrow leading-none neon-blue tracking-tighter">${serving.tokenNumber}</div>
            <div class="w-24 h-1 bg-gradient-to-r from-transparent via-blue-500 to-transparent mt-6"></div>
        `;
        grid.appendChild(div);
    });

    if (servingData.length === 0) {
        grid.innerHTML = `<div class="col-span-2 text-center text-white/20 font-tomorrow tracking-widest mt-20 animate-pulse uppercase">Waiting for stations to open...</div>`;
    }
}

function renderWaitingList(waitingTokens) {
    const list = document.getElementById('waiting-list');
    if (!list) return;
    list.innerHTML = '';

    waitingTokens.forEach((token, index) => {
        const div = document.createElement('div');
        const isNext = index === 0;
        
        div.className = `p-6 glass bg-white/5 border-white/5 flex justify-between items-center transition-all ${isNext ? 'border-blue-500/30 bg-blue-500/5 shadow-[0_0_30px_rgba(77,161,255,0.1)]' : 'opacity-60 scale-95 origin-left'}`;
        div.innerHTML = `
            <div>
               <p class="text-[10px] text-white/30 font-black tracking-widest uppercase mb-1">TOKEN</p>
               <span class="font-tomorrow text-4xl text-white">${token.tokenNumber}</span>
            </div>
            ${isNext ? '<span class="font-tomorrow text-sm bg-blue-500 text-white px-4 py-2 rounded-full font-black tracking-widest animate-pulse">NEXT</span>' : ''}
        `;
        list.appendChild(div);
    });

    if (waitingTokens.length === 0) {
        list.innerHTML = `<div class="text-center text-white/10 p-12 italic text-sm tracking-widest uppercase">The queue is currently empty</div>`;
    }
}

function playSoundAlert() {
    console.log("DING DOOONG - New Token Called!");
}

// Start polling
pollQueueStatus();
pollAnnouncements();
setInterval(pollQueueStatus, 3000); 
setInterval(pollAnnouncements, 15000); // Check announcements every 15s
