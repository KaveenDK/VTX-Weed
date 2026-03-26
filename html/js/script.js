// ==========================================
// Global Variables
// ==========================================
let currentTotalTime = 0;
let timerInterval = null;
const resourceName = 'vtx_weed';

// ==========================================
// Event Listeners for Lua Messages
// ==========================================
window.addEventListener('message', function(event) {
    const item = event.data;

    if (item.action === "openMenu") {
        openMenu(item.data, item.config);
    } else if (item.action === "showNotification") {
        showNotification(item.data);
    }
});

// ==========================================
// Main Menu Logic
// ==========================================
function openMenu(state, config) {
    // Set basic config data
    currentTotalTime = config.recipe.ProcessTime;
    
    // Update Limit Counter
    document.getElementById('limit-count').innerText = `${state.hourlyCount}/${config.limits.max}`;

    // Apply Theme Color to progress bar dynamically
    document.documentElement.style.setProperty('--theme-color', config.theme || '#1497e4');

    // Show App
    document.getElementById('app').style.display = 'flex';

    // Update View based on state
    updateView(state);
}

function closeMenu() {
    document.getElementById('app').style.display = 'none';
    if (timerInterval) clearInterval(timerInterval);
    
    // Send callback to Lua to unlock the bench
    fetch(`https://${resourceName}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function updateView(state) {
    // Hide all views first
    document.getElementById('idle-view').style.display = 'none';
    document.getElementById('processing-view').style.display = 'none';
    document.getElementById('ready-view').style.display = 'none';

    if (state.status === 'idle') {
        document.getElementById('idle-view').style.display = 'flex';
    } else if (state.status === 'processing') {
        document.getElementById('processing-view').style.display = 'flex';
        startTimer(state.finishTime);
    } else if (state.status === 'ready') {
        document.getElementById('ready-view').style.display = 'flex';
    }
}

// ==========================================
// Timer & Progress Bar Logic
// ==========================================
function startTimer(finishTime) {
    if (timerInterval) clearInterval(timerInterval);

    const timeDisplay = document.getElementById('time-remaining');
    const progressFill = document.getElementById('progress-fill');

    timerInterval = setInterval(() => {
        // Calculate remaining seconds (Unix timestamp comparison)
        const currentTime = Math.floor(Date.now() / 1000);
        const timeLeft = finishTime - currentTime;

        if (timeLeft <= 0) {
            clearInterval(timerInterval);
            timeDisplay.innerText = "Processing Complete!";
            progressFill.style.width = "100%";
            
            // Switch to ready view
            setTimeout(() => {
                updateView({ status: 'ready' });
            }, 1000);
        } else {
            // Update Text
            timeDisplay.innerText = `Time Left: ${formatTime(timeLeft)}`;
            
            // Update Progress Bar
            const progressPercent = ((currentTotalTime - timeLeft) / currentTotalTime) * 100;
            progressFill.style.width = `${progressPercent}%`;
        }
    }, 1000);
}

function formatTime(seconds) {
    const m = Math.floor(seconds / 60).toString().padStart(2, '0');
    const s = (seconds % 60).toString().padStart(2, '0');
    return `${m}:${s}`;
}

// ==========================================
// Button Click Handlers
// ==========================================
document.getElementById('close-btn').addEventListener('click', closeMenu);

document.getElementById('start-btn').addEventListener('click', function() {
    fetch(`https://${resourceName}/startProcessing`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(data => {
        if (data.success) {
            updateView(data.state);
            // Also update the limit counter
            document.getElementById('limit-count').innerText = `${data.state.hourlyCount}/3`;
        }
    });
});

document.getElementById('collect-btn').addEventListener('click', function() {
    fetch(`https://${resourceName}/collectOutput`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(data => {
        if (data.success) {
            closeMenu(); // Close UI automatically after collecting
        }
    });
});

// Close UI on Escape Key
document.addEventListener('keydown', function(event) {
    if (event.key === "Escape" && document.getElementById('app').style.display === 'flex') {
        closeMenu();
    }
});

// ==========================================
// Notification System
// ==========================================
function showNotification(data) {
    const container = document.getElementById('notification-container');
    const toast = document.createElement('div');
    toast.className = 'notify-toast';

    // Set Border Color
    toast.style.borderLeftColor = data.themeColor || '#1497e4';

    // Determine Icon
    let iconClass = 'fas fa-info-circle info';
    if (data.type === 'success') iconClass = 'fas fa-check-circle success';
    if (data.type === 'error') iconClass = 'fas fa-exclamation-circle error';

    toast.innerHTML = `
        <i class="${iconClass} notify-icon"></i>
        <div class="notify-content">
            <span class="notify-title">${data.title}</span>
            <span class="notify-message">${data.message}</span>
        </div>
    `;

    container.appendChild(toast);

    // Play Sound
    const audio = new Audio('sounds/notify.mp3');
    audio.volume = 0.5;
    audio.play().catch(e => console.log("Audio play blocked:", e));

    // Remove logic
    setTimeout(() => {
        toast.classList.add('hiding');
        setTimeout(() => {
            if (container.contains(toast)) {
                container.removeChild(toast);
            }
        }, 400); // Matches the CSS animation duration
    }, data.duration || 5000);
}