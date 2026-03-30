// ==========================================
// Global Variables
// ==========================================
let currentTotalTime = 0;
let timerInterval = null;
let currentRecipeKey = null; // Tracks whether 'Package' or 'Joint' is selected
let recipesData = {};
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

// Helper function to format raw item names (e.g. "weed_baggy_empty" -> "Weed Baggy Empty")
function formatItemName(name) {
    return name.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
}

// ==========================================
// Main Menu Logic
// ==========================================
function openMenu(state, config) {
    recipesData = config.recipes;
    
    // Generate Tabs dynamically based on Config.Bench.Recipes
    const tabsContainer = document.getElementById('recipe-tabs');
    tabsContainer.innerHTML = ''; 
    
    let firstKey = null;
    for (const key in recipesData) {
        if (!firstKey) firstKey = key;
        
        const btn = document.createElement('button');
        btn.className = 'tab-btn';
        btn.id = `tab-${key}`;
        btn.innerText = recipesData[key].Label;
        btn.onclick = () => selectRecipe(key);
        tabsContainer.appendChild(btn);
    }

    // Apply Theme Color
    document.documentElement.style.setProperty('--theme-color', config.theme || '#1497e4');

    // Show App
    document.getElementById('app').style.display = 'flex';

    // If bench is already processing/ready, lock UI to that specific recipe
    // Otherwise, default to the first recipe in the list
    if (state.status === 'processing' || state.status === 'ready') {
        selectRecipe(state.currentRecipeKey || firstKey);
        // Disable tab clicking while processing
        document.querySelectorAll('.tab-btn').forEach(b => b.style.pointerEvents = 'none');
    } else {
        selectRecipe(firstKey);
        document.querySelectorAll('.tab-btn').forEach(b => b.style.pointerEvents = 'auto');
    }

    // Update View based on state
    updateView(state);
}

function selectRecipe(key) {
    if (!recipesData[key]) return;
    
    currentRecipeKey = key;
    const recipe = recipesData[key];
    currentTotalTime = recipe.ProcessTime;

    // Update Tab Button styles
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    const activeTab = document.getElementById(`tab-${key}`);
    if (activeTab) activeTab.classList.add('active');

    // Update Input Item 1
    if (recipe.InputItems[0]) {
        document.getElementById('req-img-1').src = `images/${recipe.InputItems[0].item}.png`;
        document.getElementById('req-name-1').innerText = formatItemName(recipe.InputItems[0].item);
        document.getElementById('req-amount-1').innerText = `${recipe.InputItems[0].amount}x`;
    }

    // Update Input Item 2
    if (recipe.InputItems[1]) {
        document.getElementById('req-img-2').src = `images/${recipe.InputItems[1].item}.png`;
        document.getElementById('req-name-2').innerText = formatItemName(recipe.InputItems[1].item);
        document.getElementById('req-amount-2').innerText = `${recipe.InputItems[1].amount}x`;
    }

    // Update Output Item
    document.getElementById('out-img').src = `images/${recipe.OutputItem}.png`;
    document.getElementById('out-name').innerText = recipe.Label;
    document.getElementById('out-amount').innerText = `${recipe.OutputAmount}x`;

    // Update Processing Screen Title
    const processingTitle = document.getElementById('processing-title');
    if (processingTitle) processingTitle.innerText = `Processing ${recipe.Label}...`;
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
        // Calculate remaining seconds
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
            timeDisplay.innerText = `Time Left: ${formatTime(timeLeft)}`;
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
    // Send the currently selected recipe key to the server
    fetch(`https://${resourceName}/startProcessing`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ recipeKey: currentRecipeKey })
    }).then(resp => resp.json()).then(data => {
        if (data.success) {
            // Disable tabs so player can't click them while processing
            document.querySelectorAll('.tab-btn').forEach(b => b.style.pointerEvents = 'none');
            updateView(data.state);
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
            closeMenu();
        }
    });
});

// Close UI on Escape Key
document.addEventListener('keydown', function(event) {
    if (event.key === "Escape" && document.getElementById('app').style.display === 'flex') {
        closeMenu();
    }
});