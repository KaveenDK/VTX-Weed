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
    }
});

// ==========================================
// Main Menu Logic
// ==========================================
function openMenu(state, config) {
    // Set basic config data
    currentTotalTime = config.recipe.ProcessTime;
    
    // Dynamically set the required item amounts based on the Lua Config array
    if (config.recipe && config.recipe.InputItems) {
        // Assuming InputItems[0] is crushed_weed and InputItems[1] is weed_baggy_empty
        if (config.recipe.InputItems[0]) {
            document.getElementById('req-amount-1').innerText = `${config.recipe.InputItems[0].amount}x`;
        }
        if (config.recipe.InputItems[1]) {
            document.getElementById('req-amount-2').innerText = `${config.recipe.InputItems[1].amount}x`;
        }
    }
    
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