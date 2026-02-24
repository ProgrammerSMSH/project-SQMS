/**
 * SQMS Professional UI Utilities
 */

function showToast(message, type = 'info') {
    let container = document.getElementById('toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toast-container';
        container.className = 'fixed bottom-10 right-10 flex flex-col gap-3 z-[100]';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    const colors = {
        success: 'border-green-500/50 text-green-400 bg-green-500/5',
        error: 'border-red-500/50 text-red-400 bg-red-500/5',
        info: 'border-blue-500/50 text-blue-400 bg-blue-500/5'
    };
    
    // Professional styling with glassmorphism
    toast.className = `glass px-6 py-4 text-[10px] font-black tracking-[2px] uppercase border-l-4 shadow-2xl transition-all duration-500 translate-x-10 opacity-0 ${colors[type] || colors.info}`;
    toast.style.backdropFilter = 'blur(20px)';
    toast.style.background = 'rgba(255, 255, 255, 0.03)';
    toast.style.border = '1px solid rgba(255, 255, 255, 0.08)';
    toast.style.borderLeftWidth = '4px';
    
    toast.innerText = message;
    container.appendChild(toast);
    
    // Animate In
    setTimeout(() => {
        toast.classList.remove('translate-x-10', 'opacity-0');
    }, 10);
    
    // Auto Remove
    setTimeout(() => {
        toast.classList.add('translate-x-10', 'opacity-0');
        setTimeout(() => toast.remove(), 500);
    }, 4000);
}

// Global Export
window.showToast = showToast;
