// Vercel API Base URL
const API_URL = 'https://project-sqms.vercel.app/api/v1';
let ADMIN_TOKEN = localStorage.getItem('admin_token') || '';

// State
let counters = [];
let queues = [];
let currentCounterId = null; 
let currentQueueId = null;
let currentTokenId = null;

// UI Elements
const counterListEl = document.getElementById('counter-list');
const queueSelectEl = document.getElementById('queue-select'); // Needs to be added to HTML
const btnCallNext = document.getElementById('btn-call-next');
const btnComplete = document.getElementById('btn-complete');
const btnNoShow = document.getElementById('btn-noshow');
const currentTokenDisp = document.getElementById('current-token');
const upcomingList = document.getElementById('upcoming-list');
const counterNameDisp = document.getElementById('counter-name-disp');
const servingQueueDisp = document.getElementById('serving-queue-disp');

// Authentication Check
function checkAuth() {
    if (!ADMIN_TOKEN) {
        promptForToken();
    }
}

function promptForToken() {
    const newToken = prompt("Please enter a valid Admin Token to access the panel:");
    if (newToken) {
        ADMIN_TOKEN = newToken;
        localStorage.setItem('admin_token', newToken);
        initDashboard();
    } else {
        alert("Admin Token required.");
    }
}

// Initialization
async function initDashboard() {
    checkAuth();
    await fetchCounters();
    await fetchQueues();
    
    // Auto-select first active counter if available, else first counter
    if (counters.length > 0) {
        selectCounter(counters[0]._id);
    }
    
    // Auto-select first queue
    if (queues.length > 0) {
        currentQueueId = queues[0]._id;
        if(servingQueueDisp) servingQueueDisp.innerText = `Serving Queue: ${queues[0].name}`;
    }

    startPolling();
}

// Fetch Data
async function fetchCounters() {
    try {
        const res = await fetch(`${API_URL}/counters`, { 
            headers: { 'Authorization': `Bearer ${ADMIN_TOKEN}` } 
        });
        if (res.status === 401) {
            localStorage.removeItem('admin_token');
            ADMIN_TOKEN = '';
            promptForToken();
            return;
        }
        if (!res.ok) throw new Error(res.status);
        counters = await res.json();
        renderCounters();
    } catch (e) {
        console.error("Failed to load counters", e);
    }
}

async function fetchQueues() {
    try {
        const res = await fetch(`${API_URL}/queues`);
        if (!res.ok) throw new Error(res.status);
        queues = await res.json();
        // In a perfect UI, we'd render a dropdown for queues. 
        // For now, we'll just pick the first one seamlessly.
    } catch (e) {
        console.error("Failed to load queues", e);
    }
}

// Rendering
function renderCounters() {
    counterListEl.innerHTML = '';
    counters.forEach(counter => {
        const li = document.createElement('li');
        const isActive = counter._id === currentCounterId;
        li.className = `p-3 rounded cursor-pointer border transition-all ${
            isActive ? 'bg-blue-100 text-blue-800 font-semibold border-l-4 border-blue-600 shadow-sm' : 'hover:bg-gray-50 border-gray-100'
        }`;
        li.innerText = `${counter.name} (${counter.status})`;
        li.onclick = () => selectCounter(counter._id);
        counterListEl.appendChild(li);
    });
}

function selectCounter(id) {
    currentCounterId = id;
    const counter = counters.find(c => c._id === id);
    if(counter) {
        if(counterNameDisp) counterNameDisp.innerText = counter.name;
        currentTokenId = counter.servingTokenId?._id || null;
        currentTokenDisp.innerText = counter.servingTokenId?.tokenNumber || "--";
    }
    renderCounters();
}

// Polling Core
async function pollActiveStatus() {
    if (!currentQueueId) return;
    try {
        const res = await fetch(`${API_URL}/queues/${currentQueueId}/active-status`);
        if (!res.ok) return;
        const data = await res.json();
        
        // Update Waiting List
        upcomingList.innerHTML = '';
        data.waiting.forEach(token => {
            const li = document.createElement('li');
            li.className = 'flex justify-between items-center p-3 bg-gray-50 rounded border border-gray-200 transition-all hover:shadow-sm';
            li.innerHTML = `
                <span class="font-bold text-gray-800">${token.tokenNumber}</span>
                <span class="text-xs ${token.priority === 'EMERGENCY' ? 'bg-red-200 text-red-800' : token.priority === 'SENIOR' ? 'bg-yellow-200 text-yellow-800' : 'bg-gray-200 text-gray-600'} px-2 py-1 rounded uppercase tracking-wider font-bold">${token.priority}</span>
            `;
            upcomingList.appendChild(li);
        });

        // If another counter updates, we might want to refresh counters softly, 
        // but for this specific logged-in admin, we only care about *their* active token.
        // We rely on the button clicks to update their own view instantly.
    } catch (e) {
        console.error("Polling error", e);
    }
}

function startPolling() {
    pollActiveStatus();
    setInterval(pollActiveStatus, 3000); // Fast 3-second unified poll
}

// Actions
async function callNextToken() {
    if (!currentCounterId || !currentQueueId) return alert("Select a counter and queue first.");
    const btn = btnCallNext;
    const originalText = btn.innerText;
    btn.innerText = "CALLING...";
    btn.disabled = true;

    try {
        const response = await fetch(`${API_URL}/counters/${currentCounterId}/call-next`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${ADMIN_TOKEN}` },
            body: JSON.stringify({ queueId: currentQueueId })
        });
        
        if (!response.ok) {
            if (response.status === 401) promptForToken();
            else throw new Error(await response.text());
        } else {
            const token = await response.json();
            currentTokenId = token._id;
            currentTokenDisp.innerText = token.tokenNumber;
            // Immediate UI update for snappiness
            pollActiveStatus(); 
        }
    } catch (error) {
        alert("Error calling next: " + error.message);
    } finally {
        btn.innerText = originalText;
        btn.disabled = false;
    }
}

async function handleTokenAction(action) { // 'complete' or 'no-show'
    if(!currentTokenId || !currentCounterId) return;
    try {
        const res = await fetch(`${API_URL}/counters/${currentCounterId}/${action}`, { 
            method: 'POST', headers: { 'Authorization': `Bearer ${ADMIN_TOKEN}` }
        });
        if (!res.ok) {
            if (res.status === 401) promptForToken();
            else throw new Error(await res.text());
        }
        currentTokenDisp.innerText = "--";
        currentTokenId = null;
    } catch (e) {
        alert(`Error marking ${action}: ` + e.message);
    }
}

// Event Listeners
btnCallNext.addEventListener('click', callNextToken);
btnComplete.addEventListener('click', () => handleTokenAction('complete'));
btnNoShow.addEventListener('click', () => handleTokenAction('no-show'));

// Boot
initDashboard();
