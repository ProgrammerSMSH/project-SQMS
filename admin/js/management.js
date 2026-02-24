const API_URL = 'https://project-sqms.vercel.app/api/v1';

// Internal State
let userToken = localStorage.getItem('admin_token');
let currentTab = 'services';
let dataList = [];
let staffList = []; // Global cache for staff assignment dropdown
let editingId = null;

// UI Elements
const mainContent = document.getElementById('main-content');
const tabBtns = document.querySelectorAll('.tab-btn');
const tabTitle = document.getElementById('tab-title');
const tabDesc = document.getElementById('tab-desc');
const dataTableHead = document.querySelector('#data-table thead tr');
const dataBody = document.getElementById('data-body');
const addNewBtn = document.getElementById('add-new-btn');
const loadingSpinner = document.getElementById('loading-spinner');
const logoutBtn = document.getElementById('logout-btn');

// Modal Elements
const modal = document.getElementById('form-modal');
const modalContent = modal.querySelector('.modal-content');
const modalTitle = document.getElementById('modal-title');
const crudForm = document.getElementById('crud-form');
const formFieldsContainer = document.getElementById('form-fields');
const formError = document.getElementById('form-error');

// Auth Check
console.log('Management panel initializing. Token present:', !!userToken);
if (!userToken) {
    console.warn('No admin token found. Redirecting to login in 2 seconds.');
    setTimeout(() => { window.location.href = 'index.html'; }, 2000);
} else {
    mainContent.classList.remove('opacity-0');
    loadData();
}

// Event Listeners
logoutBtn.addEventListener('click', () => {
    localStorage.removeItem('admin_token');
    window.location.href = 'index.html';
});

tabBtns.forEach(btn => {
    btn.addEventListener('click', (e) => {
        tabBtns.forEach(b => {
            b.classList.remove('active', 'text-white');
            b.classList.add('text-white/50');
        });
        e.target.classList.add('active', 'text-white');
        e.target.classList.remove('text-white/50');
        
        currentTab = e.target.dataset.tab;
        updateTabHeader();
        loadData();
    });
});

addNewBtn.addEventListener('click', () => {
    editingId = null;
    openModal(`Add New ${getTabSingularName()}`);
});

document.getElementById('close-modal').addEventListener('click', closeModal);
document.getElementById('cancel-btn').addEventListener('click', closeModal);

crudForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    formError.classList.add('hidden');
    
    // Gather form data
    const formData = new FormData(crudForm);
    const payload = {};
    
    if (currentTab === 'services') {
        payload.name = formData.get('name');
        payload.code = formData.get('code');
        payload.avgWaitTimePerToken = parseInt(formData.get('avgWaitTimePerToken'), 10);
        payload.isActive = formData.get('isActive') === 'on';
    } else if (currentTab === 'counters') {
        payload.name = formData.get('name');
        payload.assignedStaffId = formData.get('assignedStaffId') || null;
        if (editingId) payload.status = formData.get('status');
    } else if (currentTab === 'staff') {
        payload.name = formData.get('name');
        payload.email = formData.get('email');
        if (!editingId) payload.password = formData.get('password');
        payload.phone = formData.get('phone');
    } else if (currentTab === 'announcements') {
        payload.message = formData.get('message');
        payload.isActive = formData.get('isActive') === 'on';
    }

    try {
        const url = editingId ? `${getEndpoint()}/${editingId}` : getEndpoint();
        const method = editingId ? 'PUT' : 'POST';
        
        const res = await fetch(url, {
            method,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${userToken}`
            },
            body: JSON.stringify(payload)
        });

        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Action failed');
        
        showToast(`${getTabSingularName()} ${editingId ? 'updated' : 'created'} successfully!`, 'success');
        closeModal();
        loadData();
    } catch (err) {
        formError.textContent = err.message;
        formError.classList.remove('hidden');
    }
});

// Helpers
function getEndpoint() {
    switch(currentTab) {
        case 'services': return `${API_URL}/queues`;
        case 'counters': return `${API_URL}/counters`;
        case 'staff': return `${API_URL}/users/staff`;
        case 'announcements': return `${API_URL}/announcements`;
    }
}

function getTabSingularName() {
    switch(currentTab) {
        case 'services': return 'Service';
        case 'counters': return 'Counter';
        case 'staff': return 'Staff Member';
        case 'announcements': return 'Announcement';
    }
}

function updateTabHeader() {
    switch(currentTab) {
        case 'services':
            tabTitle.textContent = 'Manage Services';
            tabDesc.textContent = 'Configure the active queues available to users.';
            dataTableHead.innerHTML = `<th>Name</th><th>Code</th><th>Avg Wait (mins)</th><th>Status</th><th class="text-right">Actions</th>`;
            break;
        case 'counters':
            tabTitle.textContent = 'Manage Counters';
            tabDesc.textContent = 'Configure operator stations and their assigned staff.';
            dataTableHead.innerHTML = `<th>Name</th><th>Status</th><th>Assigned Staff</th><th>Serving</th><th class="text-right">Actions</th>`;
            break;
        case 'staff':
            tabTitle.textContent = 'Staff Members';
            tabDesc.textContent = 'Manage staff accounts that can manage specific counters.';
            dataTableHead.innerHTML = `<th>Name</th><th>Email</th><th>Phone</th><th class="text-right">Actions</th>`;
            break;
        case 'announcements':
            tabTitle.textContent = 'Manage Announcements';
            tabDesc.textContent = 'Configure scrolling text messages for the TV Display.';
            dataTableHead.innerHTML = `<th>Message</th><th>Status</th><th>Created</th><th class="text-right">Actions</th>`;
            break;
    }
}

async function loadData() {
    loadingSpinner.classList.remove('hidden');
    dataBody.innerHTML = '';
    
    // Always fetch staff in background if we might need them for assignment
    if (currentTab === 'counters' || currentTab === 'staff') {
        try {
            const sRes = await fetch(`${API_URL}/users/staff`, { headers: { 'Authorization': `Bearer ${userToken}` }});
            if (sRes.ok) staffList = await sRes.json();
        } catch(e) {}
    }
    try {
        const res = await fetch(getEndpoint(), {
            headers: {
                'Authorization': `Bearer ${userToken}`
            }
        });
        
        if (res.status === 401) {
            localStorage.removeItem('admin_token');
            window.location.href = 'index.html';
            return;
        }

        dataList = await res.json();
        renderTableOutput();
    } catch (e) {
        console.error("Failed to load data", e);
    } finally {
        loadingSpinner.classList.add('hidden');
    }
}

function renderTableOutput() {
    if (!dataList || dataList.length === 0) {
        dataBody.innerHTML = `<tr><td colspan="5" class="text-center py-12 text-white/20 italic tracking-widest uppercase text-xs">No records found</td></tr>`;
        return;
    }

    dataBody.innerHTML = dataList.map(item => {
        let cells = '';
        if (currentTab === 'services') {
            const statusBadge = item.isActive ? `<span class="bg-green-500/20 text-green-400 px-2 py-1 rounded border border-green-500/20 text-[10px] uppercase font-bold tracking-widest">Active</span>` : `<span class="bg-red-500/20 text-red-400 px-2 py-1 rounded border border-red-500/20 text-[10px] uppercase font-bold tracking-widest">Inactive</span>`;
            cells = `
                <td class="font-bold">${item.name}</td>
                <td class="font-tomorrow text-blue-400">${item.code}</td>
                <td>${item.avgWaitTimePerToken}</td>
                <td>${statusBadge}</td>
            `;
        } else if (currentTab === 'counters') {
            const statusColor = item.status === 'ACTIVE' ? 'text-green-400' : (item.status === 'CLOSED' ? 'text-red-400' : 'text-yellow-400');
            const token = item.servingTokenId ? item.servingTokenId.tokenNumber : '--';
            const staffName = item.assignedStaffId ? item.assignedStaffId.name : '<span class="text-white/20 italic">Unassigned</span>';
            cells = `
                <td class="font-bold font-tomorrow uppercase">${item.name}</td>
                <td class="${statusColor} text-xs font-bold tracking-widest uppercase">${item.status}</td>
                <td class="text-xs">${staffName}</td>
                <td class="font-tomorrow text-white/50">${token}</td>
            `;
        } else if (currentTab === 'staff') {
            cells = `
                <td class="font-bold">${item.name}</td>
                <td class="text-blue-400">${item.email}</td>
                <td class="text-white/50 text-xs">${item.phone || '--'}</td>
            `;
        } else if (currentTab === 'announcements') {
            const statusBadge = item.isActive ? `<span class="bg-green-500/20 text-green-400 px-2 py-1 rounded border border-green-500/20 text-[10px] uppercase font-bold tracking-widest">Active</span>` : `<span class="bg-red-500/20 text-red-400 px-2 py-1 rounded border border-red-500/20 text-[10px] uppercase font-bold tracking-widest">Inactive</span>`;
            const date = new Date(item.createdAt).toLocaleDateString();
            cells = `
                <td class="max-w-xs truncate" title="${item.message}">${item.message}</td>
                <td>${statusBadge}</td>
                <td class="text-white/50 text-xs">${date}</td>
            `;
        }

        return `
            <tr class="table-row border-b border-transparent">
                ${cells}
                <td class="text-right">
                    <button onclick="editItem('${item._id}')" class="text-blue-400 hover:text-blue-300 transition mr-4 uppercase text-[10px] tracking-widest font-bold">Edit</button>
                    <button onclick="deleteItem('${item._id}')" class="text-red-400 hover:text-red-300 transition uppercase text-[10px] tracking-widest font-bold">Delete</button>
                </td>
            </tr>
        `;
    }).join('');
}

// Modal Form Building
function openModal(title) {
    modalTitle.textContent = title;
    formError.classList.add('hidden');
    
    let fieldsHtml = '';
    const item = editingId ? dataList.find(i => i._id === editingId) : null;

    if (currentTab === 'services') {
        fieldsHtml = `
            <div>
                <label class="block text-xs uppercase tracking-widest text-white/50 mb-2">Service Name</label>
                <input type="text" name="name" required value="${item ? item.name : ''}" class="w-full input-glass rounded-xl p-3 text-sm focus:ring-0">
            </div>
            <div>
                <label class="block text-xs uppercase tracking-widest text-white/50 mb-2">Queue Code (e.g. GN)</label>
                <input type="text" name="code" required value="${item ? item.code : ''}" class="w-full input-glass rounded-xl p-3 text-sm focus:ring-0">
            </div>
            <div>
                <label class="block text-xs uppercase tracking-widest text-white/50 mb-2">Avg Wait Time (mins)</label>
                <input type="number" name="avgWaitTimePerToken" required value="${item ? item.avgWaitTimePerToken : '5'}" class="w-full input-glass rounded-xl p-3 text-sm focus:ring-0">
            </div>
            <label class="flex items-center gap-3 mt-2 cursor-pointer">
                <input type="checkbox" name="isActive" ${!item || item.isActive ? 'checked' : ''} class="w-5 h-5 rounded border-gray-600 bg-gray-700 text-blue-500 focus:ring-blue-500 focus:ring-offset-gray-800">
                <span class="text-sm font-bold tracking-widest uppercase">Service is Active</span>
            </label>
        `;
    } else if (currentTab === 'counters') {
        fieldsHtml = `
            <div>
                <label class="block text-xs uppercase tracking-widest text-white/50 mb-2">Counter Name</label>
                <input type="text" name="name" required value="${item ? item.name : ''}" class="w-full input-glass rounded-xl p-3 text-sm focus:ring-0">
            </div>
            <div>
                <label class="block text-xs uppercase tracking-widest text-white/50 mb-2 mt-4">Assign Staff</label>
                <select name="assignedStaffId" class="w-full input-glass rounded-xl p-3 text-sm focus:ring-0 [&>option]:text-black">
                    <option value="">No Staff Assigned</option>
                    ${staffList.map(s => `<option value="${s._id}" ${item && item.assignedStaffId && item.assignedStaffId._id === s._id ? 'selected' : ''}>${s.name} (${s.email})</option>`).join('')}
                </select>
            </div>
        `;
        if (editingId) {
            fieldsHtml += `
            <div>
                <label class="block text-xs uppercase tracking-widest text-white/50 mb-2 mt-4">Status</label>
                <select name="status" class="w-full input-glass rounded-xl p-3 text-sm focus:ring-0 [&>option]:text-black">
                    <option value="ACTIVE" ${item.status === 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                    <option value="PAUSED" ${item.status === 'PAUSED' ? 'selected' : ''}>PAUSED</option>
                    <option value="CLOSED" ${item.status === 'CLOSED' ? 'selected' : ''}>CLOSED</option>
                </select>
            </div>`;
        }
    } else if (currentTab === 'staff') {
        fieldsHtml = `
            <div>
                <label class="block text-xs uppercase tracking-widest text-white/50 mb-2">Staff Name</label>
                <input type="text" name="name" required value="${item ? item.name : ''}" class="w-full input-glass rounded-xl p-3 text-sm focus:ring-0">
            </div>
            <div>
                <label class="block text-xs uppercase tracking-widest text-white/50 mb-2 mt-4">Email Address</label>
                <input type="email" name="email" required value="${item ? item.email : ''}" class="w-full input-glass rounded-xl p-3 text-sm focus:ring-0">
            </div>
            ${!editingId ? `
            <div>
                <label class="block text-xs uppercase tracking-widest text-white/50 mb-2 mt-4">Password</label>
                <input type="password" name="password" required class="w-full input-glass rounded-xl p-3 text-sm focus:ring-0">
            </div>
            ` : ''}
            <div>
                <label class="block text-xs uppercase tracking-widest text-white/50 mb-2 mt-4">Phone (Optional)</label>
                <input type="text" name="phone" value="${item ? item.phone || '' : ''}" class="w-full input-glass rounded-xl p-3 text-sm focus:ring-0">
            </div>
        `;
    } else if (currentTab === 'announcements') {
        fieldsHtml = `
            <div>
                <label class="block text-xs uppercase tracking-widest text-white/50 mb-2">Message</label>
                <textarea name="message" required rows="3" class="w-full input-glass rounded-xl p-3 text-sm focus:ring-0">${item ? item.message : ''}</textarea>
            </div>
            <label class="flex items-center gap-3 mt-2 cursor-pointer">
                <input type="checkbox" name="isActive" ${!item || item.isActive ? 'checked' : ''} class="w-5 h-5 rounded border-gray-600 bg-gray-700 text-blue-500 focus:ring-blue-500 focus:ring-offset-gray-800">
                <span class="text-sm font-bold tracking-widest uppercase">Show on TV</span>
            </label>
        `;
    }

    formFieldsContainer.innerHTML = fieldsHtml;
    
    modal.classList.remove('opacity-0', 'pointer-events-none');
    setTimeout(() => modalContent.classList.remove('scale-95'), 10);
}

function closeModal() {
    modalContent.classList.add('scale-95');
    modal.classList.add('opacity-0', 'pointer-events-none');
    setTimeout(() => crudForm.reset(), 300);
}

// Global actions for inline buttons
window.editItem = (id) => {
    editingId = id;
    openModal(`Edit ${getTabSingularName()}`);
};

window.deleteItem = async (id) => {
    if (!confirm(`Are you sure you want to delete this ${getTabSingularName()}?`)) return;
    try {
        const res = await fetch(`${getEndpoint()}/${id}`, {
            method: 'DELETE',
            headers: { 'Authorization': `Bearer ${userToken}` }
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Delete failed');
        showToast(`${getTabSingularName()} deleted.`, 'success');
        loadData();
    } catch (e) {
        alert(e.message);
    }
};

// Init
updateTabHeader();
