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
const queueSelector = document.getElementById('queue-selector');
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
        const selector = document.getElementById('queue-selector');
        if (selector) selector.value = currentQueueId;
        updateTvLink();
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
        
        if (queueSelector) {
            queueSelector.innerHTML = '';
            queues.forEach(q => {
                const opt = document.createElement('option');
                opt.value = q._id;
                opt.textContent = `${q.name} (${q.code})`;
                queueSelector.appendChild(opt);
            });

            // Bind change event
            queueSelector.addEventListener('change', (e) => {
                currentQueueId = e.target.value;
                updateTvLink();
                pollActiveStatus();
                showToast(`Queue switched to: ${queues.find(q => q._id === currentQueueId)?.name}`, 'info');
            });
        }
    } catch (e) {
        console.error("Failed to load queues", e);
    }
}

function updateTvLink() {
    const tvBtn = document.getElementById('open-tv-btn');
    if (tvBtn && currentQueueId) {
        tvBtn.href = `tv-display.html?queueId=${currentQueueId}`;
    }
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
        
        // Add a "pop" animation
        currentTokenDisp.classList.remove('animate-pulse');
        void currentTokenDisp.offsetWidth;
        currentTokenDisp.classList.add('animate-pulse');
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
                    ${(() => {
                        const priorityColors = {
                            'EMERGENCY': 'bg-red-500/20 text-red-400 border-red-500/20',
                            'SENIOR': 'bg-yellow-500/20 text-yellow-400 border-yellow-500/20',
                            'GENERAL': 'bg-blue-500/20 text-blue-400 border-blue-500/20'
                        };
                        const priorityClass = priorityColors[token.priority] || priorityColors['GENERAL'];
                        return `<span class="text-[9px] ${priorityClass} px-2 py-1 rounded border uppercase tracking-widest font-black">${token.priority}</span>`;
                    })()}
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

// Helpers
function setBtnLoading(btn, isLoading, originalText) {
    if (isLoading) {
        btn.disabled = true;
        btn.innerHTML = `<span class="animate-pulse">PROCESSING...</span>`;
        btn.classList.add('opacity-50', 'cursor-not-allowed');
    } else {
        btn.disabled = false;
        btn.innerHTML = originalText;
        btn.classList.remove('opacity-50', 'cursor-not-allowed');
    }
}

// Actions
async function callNextToken() {
    if (!currentCounterId || !currentQueueId) return showToast("Select a counter and queue first.", 'error');
    
    const originalText = btnCallNext.innerHTML;
    try {
        setBtnLoading(btnCallNext, true, originalText);
        const response = await fetch(`${API_URL}/queues/${currentQueueId}/call-next`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
            },
            body: JSON.stringify({ counterId: currentCounterId })
        });

        if (response.status === 401) {
            showLoginModal();
            return;
        }

        if (response.status === 404) {
            showToast("No tokens waiting in this queue.", "info");
        } else if (!response.ok) {
            const err = await response.json();
            throw new Error(err.message || "Failed to call next");
        } else {
            const token = await response.json();
            currentTokenId = token._id;
            currentTokenDisp.innerText = token.tokenNumber;
            showToast(`Called Token: ${token.tokenNumber}`, 'success');
            pollActiveStatus(); 
        }
    } catch (error) {
        showToast(error.message, "error");
    } finally {
        setBtnLoading(btnCallNext, false, originalText);
    }
}

async function handleTokenAction(action) {
    if (!currentTokenId || !currentCounterId) return showToast("No token currently being served.", 'error');
    
    const btn = action === 'no-show' ? btnNoShow : btnComplete;
    const originalText = btn.innerHTML;

    try {
        setBtnLoading(btn, true, originalText);
        const res = await fetch(`${API_URL}/tokens/${currentTokenId}/${action}`, {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${localStorage.getItem('admin_token')}`
            },
            body: JSON.stringify({ counterId: currentCounterId })
        });

        if (!res.ok) {
            if (res.status === 401) showLoginModal();
            else throw new Error(await res.text());
        }
        showToast(action === 'no-show' ? 'Token marked as No-Show' : 'Token Service Completed!', 'success');
        currentTokenDisp.innerText = "--";
        currentTokenId = null;
        pollActiveStatus();
    } catch (e) {
        showToast(e.message, 'error');
    } finally {
        setBtnLoading(btn, false, originalText);
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
