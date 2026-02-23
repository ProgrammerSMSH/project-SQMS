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
        showLoginModal();
    } else {
        initDashboard();
    }
}

function showLoginModal() {
    const modal = document.getElementById('login-modal');
    if (modal) {
        modal.classList.remove('hidden');
    }
}

function hideLoginModal() {
    const modal = document.getElementById('login-modal');
    if (modal) {
        modal.classList.add('hidden');
    }
}

// Login Handler
async function handleLogin(email, password) {
    const errorEl = document.getElementById('login-error');
    if (errorEl) errorEl.classList.add('hidden');

    try {
        const response = await fetch(`${API_URL}/auth/admin-login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });

        if (!response.ok) {
            throw new Error('Login failed');
        }

        const data = await response.json();
        ADMIN_TOKEN = data.token;
        localStorage.setItem('admin_token', ADMIN_TOKEN);
        
        hideLoginModal();
        initDashboard();
    } catch (error) {
        if (errorEl) {
            errorEl.innerText = "ACCESS DENIED: INVALID CREDENTIALS";
            errorEl.classList.remove('hidden');
        }
    }
}

// Initialization
async function initDashboard() {
    // Only fetch if we have a token
    if (!ADMIN_TOKEN) return;
    
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
            showLoginModal();
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
        if (data.waiting.length === 0) {
            upcomingList.innerHTML = '<li class="p-8 text-white/10 text-center italic text-xs">No active queue</li>';
        }
        data.waiting.forEach(token => {
            const li = document.createElement('li');
            li.className = 'flex justify-between items-center p-4 glass bg-white/5 border-white/5 transition-all hover:bg-white/10 group';
            li.innerHTML = `
                <div>
                     <p class="text-[10px] text-white/30 font-black tracking-widest uppercase mb-1">TOKEN</p>
                     <span class="font-tomorrow text-xl text-white group-hover:text-blue-400 transition">${token.tokenNumber}</span>
                </div>
                <div class="text-right">
                    <span class="text-[9px] ${token.priority === 'EMERGENCY' ? 'text-red-400 border-red-400/30 bg-red-400/10' : token.priority === 'SENIOR' ? 'text-yellow-400 border-yellow-400/30 bg-yellow-400/10' : 'text-blue-400 border-blue-400/30 bg-blue-400/10'} px-2 py-1 rounded border uppercase tracking-widest font-black">${token.priority}</span>
                </div>
            `;
            upcomingList.appendChild(li);
        });
    } catch (e) {
        console.error("Polling error", e);
    }
}

function startPolling() {
    pollActiveStatus();
    setInterval(pollActiveStatus, 3000); // 3-second unified poll
}

// Rendering
function renderCounters() {
    counterListEl.innerHTML = '';
    counters.forEach(counter => {
        const li = document.createElement('li');
        const isActive = counter._id === currentCounterId;
        li.className = `p-4 rounded-xl cursor-pointer border transition-all ${
            isActive ? 'active-counter border-blue-500/50 shadow-[0_0_20px_rgba(77,161,255,0.1)]' : 'bg-white/5 border-white/5 hover:bg-white/10'
        }`;
        li.innerHTML = `
            <div class="flex justify-between items-center">
                <span class="font-tomorrow text-sm tracking-tight ${isActive ? 'text-blue-400' : 'text-white/70'}">${counter.name}</span>
                <span class="text-[8px] px-2 py-1 rounded bg-black/40 text-white/40 font-black tracking-widest uppercase">${counter.status}</span>
            </div>
        `;
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

// Actions
async function callNextToken() {
    if (!currentCounterId || !currentQueueId) return alert("Select a counter and queue first.");
    const btn = btnCallNext;
    const originalContent = btn.innerHTML;
    btn.innerHTML = '<span class="animate-pulse">CALLING...</span>';
    btn.disabled = true;

    try {
        const response = await fetch(`${API_URL}/counters/${currentCounterId}/call-next`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${ADMIN_TOKEN}` },
            body: JSON.stringify({ queueId: currentQueueId })
        });
        
        if (!response.ok) {
            if (response.status === 401) showLoginModal();
            else {
                const errorText = await response.text();
                // Simple toast-like alert for now
                alert("Queue Issue: " + errorText);
            }
        } else {
            const token = await response.json();
            currentTokenId = token._id;
            currentTokenDisp.innerText = token.tokenNumber;
            pollActiveStatus(); 
        }
    } catch (error) {
        alert("Connection Error: " + error.message);
    } finally {
        btn.innerHTML = originalContent;
        btn.disabled = false;
    }
}

async function handleTokenAction(action) { 
    if(!currentTokenId || !currentCounterId) return;
    try {
        const res = await fetch(`${API_URL}/counters/${currentCounterId}/${action}`, { 
            method: 'POST', headers: { 'Authorization': `Bearer ${ADMIN_TOKEN}` }
        });
        if (!res.ok) {
            if (res.status === 401) showLoginModal();
            else throw new Error(await res.text());
        }
        currentTokenDisp.innerText = "--";
        currentTokenId = null;
    } catch (e) {
        alert(`Error: ` + e.message);
    }
}

function handleLogout() {
    localStorage.removeItem('admin_token');
    ADMIN_TOKEN = '';
    location.reload();
}

// Event Listeners
btnCallNext.addEventListener('click', callNextToken);
btnComplete.addEventListener('click', () => handleTokenAction('complete'));
btnNoShow.addEventListener('click', () => handleTokenAction('no-show'));
document.getElementById('logout-btn')?.addEventListener('click', handleLogout);

document.getElementById('login-form')?.addEventListener('submit', (e) => {
    e.preventDefault();
    const email = document.getElementById('admin-email').value;
    const password = document.getElementById('admin-password').value;
    handleLogin(email, password);
});

// Boot
checkAuth();
