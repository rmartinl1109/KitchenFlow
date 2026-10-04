/**
 * KitchenFlow - Official App Showcase
 * Clean Vanilla ES6 JavaScript for interactive demo & theme controls
 */

// State
const appState = {
  currentScreen: 'activeCooking',
  isDarkMode: window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches,
  cookingSecondsRemaining: 145,
  isPaused: false
};

// Render screens in the in-browser iPhone mockup
function renderPhoneDemo() {
  const viewport = document.getElementById('demo-viewport');
  if (!viewport) return;

  if (appState.currentScreen === 'activeCooking') {
    viewport.innerHTML = `
      <div class="flex-1 flex flex-col justify-between py-1 text-center select-none">
        <!-- Header -->
        <div class="space-y-1">
          <span class="text-[10px] font-bold tracking-wider uppercase text-amber-600 dark:text-amber-400">Step 2 of 4</span>
          <h4 class="font-bold text-sm text-zinc-900 dark:text-white leading-tight">
            Sauté Shallots & Mushrooms
          </h4>
        </div>

        <!-- Nested Interval Notice Banner -->
        <div class="bg-gradient-to-r from-orange-500 to-amber-500 text-white rounded-xl p-2.5 shadow-md shadow-orange-500/20 text-left flex items-center justify-between my-2">
          <div class="flex items-center space-x-2">
            <i data-lucide="bell-ring" class="w-4 h-4 animate-bounce"></i>
            <div>
              <p class="text-[10px] font-bold uppercase tracking-wider">Interval Alert</p>
              <p class="text-xs font-semibold">Stir gently & watch heat</p>
            </div>
          </div>
          <button id="demo-btn-dismiss-alert" class="px-2 py-1 bg-white/20 hover:bg-white/30 rounded-md text-[10px] font-bold">
            Done
          </button>
        </div>

        <!-- Circular Timer Visualizer -->
        <div class="relative w-40 h-40 mx-auto my-auto flex items-center justify-center">
          <svg class="w-full h-full transform -rotate-90" viewBox="0 0 100 100">
            <circle cx="50" cy="50" r="42" stroke="currentColor" stroke-width="8" class="text-zinc-200 dark:text-zinc-800" fill="transparent"/>
            <circle cx="50" cy="50" r="42" stroke="url(#timerGradient)" stroke-width="8" stroke-dasharray="264" stroke-dashoffset="75" stroke-linecap="round" fill="transparent"/>
            <defs>
              <linearGradient id="timerGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stop-color="#F59E0B"/>
                <stop offset="100%" stop-color="#EA580C"/>
              </linearGradient>
            </defs>
          </svg>
          <div class="absolute inset-0 flex flex-col items-center justify-center">
            <span class="text-2xl font-black tracking-tight text-zinc-900 dark:text-white font-mono">
              02:25
            </span>
            <span class="text-[10px] font-medium text-zinc-500 dark:text-zinc-400">
              Remaining
            </span>
          </div>
        </div>

        <!-- Next Step Preview -->
        <div class="bg-zinc-100 dark:bg-zinc-800/80 rounded-xl p-2 text-left text-xs mb-2">
          <span class="text-[10px] font-bold text-zinc-400 uppercase">Next Step</span>
          <p class="font-medium text-zinc-700 dark:text-zinc-300 truncate">Toast arborio rice & deglaze wine</p>
        </div>

        <!-- Action Controls -->
        <div class="flex items-center space-x-2 pt-1">
          <button id="demo-btn-pause" class="flex-1 py-2.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-white font-semibold text-xs transition active:scale-95 flex items-center justify-center space-x-1.5 shadow-sm">
            <i data-lucide="pause" class="w-3.5 h-3.5"></i>
            <span>Pause</span>
          </button>
          <button id="demo-btn-skip" class="px-4 py-2.5 rounded-xl bg-zinc-200 dark:bg-zinc-800 hover:bg-zinc-300 text-zinc-800 dark:text-zinc-200 font-semibold text-xs transition active:scale-95 flex items-center justify-center space-x-1">
            <i data-lucide="skip-forward" class="w-3.5 h-3.5"></i>
            <span>Next</span>
          </button>
        </div>
      </div>
    `;
  } else if (appState.currentScreen === 'recipeList') {
    viewport.innerHTML = `
      <div class="flex-1 flex flex-col justify-between py-1 text-left space-y-2">
        <div class="flex items-center justify-between pb-1 border-b border-zinc-200 dark:border-zinc-800">
          <div>
            <h4 class="font-bold text-base text-zinc-900 dark:text-white">KitchenFlow</h4>
            <p class="text-[11px] text-zinc-500 dark:text-zinc-400">Smart Recipe Timers</p>
          </div>
          <button id="demo-btn-new-recipe" class="w-7 h-7 rounded-full bg-amber-500 text-white flex items-center justify-center hover:scale-105 transition shadow-sm">
            <i data-lucide="plus" class="w-4 h-4"></i>
          </button>
        </div>

        <div class="space-y-2 overflow-y-auto max-h-[300px] pr-1">
          <!-- Recipe Card 1 -->
          <div class="p-3 rounded-2xl bg-white dark:bg-zinc-800/90 border border-zinc-200 dark:border-zinc-700/80 shadow-sm space-y-2">
            <div class="flex items-start space-x-3">
              <span class="text-2xl p-2 rounded-xl bg-amber-100 dark:bg-amber-900/40">🍲</span>
              <div class="flex-1 min-w-0">
                <h5 class="font-bold text-xs text-zinc-900 dark:text-white truncate">Wild Mushroom Risotto</h5>
                <p class="text-[10px] text-zinc-500 dark:text-zinc-400 line-clamp-1">Precise phased timers for perfect creaminess</p>
              </div>
            </div>
            <div class="flex items-center justify-between pt-1 text-[11px]">
              <span class="text-zinc-500 dark:text-zinc-400 flex items-center gap-1">
                <i data-lucide="clock" class="w-3 h-3 text-amber-500"></i> 19m (4 steps)
              </span>
              <button id="demo-btn-cook-now" class="px-2.5 py-1 rounded-lg bg-gradient-to-r from-amber-500 to-orange-500 text-white font-semibold text-[10px] hover:opacity-95 transition shadow-sm">
                Cook Now
              </button>
            </div>
          </div>

          <!-- Recipe Card 2 -->
          <div class="p-3 rounded-2xl bg-white dark:bg-zinc-800/90 border border-zinc-200 dark:border-zinc-700/80 shadow-sm space-y-2">
            <div class="flex items-start space-x-3">
              <span class="text-2xl p-2 rounded-xl bg-orange-100 dark:bg-orange-900/40">🍝</span>
              <div class="flex-1 min-w-0">
                <h5 class="font-bold text-xs text-zinc-900 dark:text-white truncate">Slow-Cooked Bolognese</h5>
                <p class="text-[10px] text-zinc-500 dark:text-zinc-400 line-clamp-1">Brown, simmer, and reduce with 15m stir intervals</p>
              </div>
            </div>
            <div class="flex items-center justify-between pt-1 text-[11px]">
              <span class="text-zinc-500 dark:text-zinc-400 flex items-center gap-1">
                <i data-lucide="clock" class="w-3 h-3 text-orange-500"></i> 45m (5 steps)
              </span>
              <span class="text-[10px] font-semibold text-amber-600 dark:text-amber-400">Pro</span>
            </div>
          </div>
        </div>

        <div class="p-2 rounded-xl bg-amber-500/10 border border-amber-500/20 text-center">
          <p class="text-[10px] text-amber-800 dark:text-amber-300 font-medium">
            ✨ Free Tier includes nested timers & interval alerts!
          </p>
        </div>
      </div>
    `;
  } else if (appState.currentScreen === 'recipeEditor') {
    viewport.innerHTML = `
      <div class="flex-1 flex flex-col justify-between py-1 text-left space-y-2">
        <h4 class="font-bold text-sm text-zinc-900 dark:text-white">Recipe Script Editor</h4>
        
        <div class="space-y-2 text-xs">
          <div>
            <label class="text-[10px] font-bold uppercase text-zinc-400">Recipe Name</label>
            <input type="text" value="Seared Salmon & Lemon Butter" class="w-full px-2.5 py-1.5 rounded-lg bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs" readonly />
          </div>

          <div class="p-2 rounded-xl bg-zinc-100 dark:bg-zinc-800/80 space-y-1.5">
            <div class="flex justify-between items-center">
              <span class="font-bold text-[11px]">Phase 1: Sear Skin</span>
              <span class="text-[10px] text-amber-600 font-semibold">4m 00s</span>
            </div>
            <p class="text-[10px] text-zinc-500">Nested alert: Flip gently at 3m</p>
          </div>

          <div class="p-2 rounded-xl bg-zinc-100 dark:bg-zinc-800/80 space-y-1.5">
            <div class="flex justify-between items-center">
              <span class="font-bold text-[11px]">Phase 2: Butter Basting</span>
              <span class="text-[10px] text-amber-600 font-semibold">2m 30s</span>
            </div>
            <p class="text-[10px] text-zinc-500">Repeats every 30s: Spoon melted butter</p>
          </div>
        </div>

        <button id="demo-btn-save-recipe" class="w-full py-2.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-white font-semibold text-xs transition active:scale-95">
          Save Recipe Script
        </button>
      </div>
    `;
  }

  // Re-init lucide icons inside demo
  if (window.lucide) {
    window.lucide.createIcons();
  }

  // Bind demo-internal buttons
  attachDemoEvents();
}

function attachDemoEvents() {
  const dismissAlertBtn = document.getElementById('demo-btn-dismiss-alert');
  if (dismissAlertBtn) {
    dismissAlertBtn.addEventListener('click', () => {
      dismissAlertBtn.parentElement.classList.add('opacity-40');
    });
  }

  const pauseBtn = document.getElementById('demo-btn-pause');
  if (pauseBtn) {
    pauseBtn.addEventListener('click', () => {
      appState.isPaused = !appState.isPaused;
      pauseBtn.querySelector('span').textContent = appState.isPaused ? 'Resume' : 'Pause';
    });
  }

  const skipBtn = document.getElementById('demo-btn-skip');
  if (skipBtn) {
    skipBtn.addEventListener('click', () => {
      setDemoScreen('recipeList');
    });
  }

  const cookNowBtn = document.getElementById('demo-btn-cook-now');
  if (cookNowBtn) {
    cookNowBtn.addEventListener('click', () => {
      setDemoScreen('activeCooking');
    });
  }

  const newRecipeBtn = document.getElementById('demo-btn-new-recipe');
  if (newRecipeBtn) {
    newRecipeBtn.addEventListener('click', () => {
      setDemoScreen('recipeEditor');
    });
  }

  const saveRecipeBtn = document.getElementById('demo-btn-save-recipe');
  if (saveRecipeBtn) {
    saveRecipeBtn.addEventListener('click', () => {
      setDemoScreen('recipeList');
    });
  }
}

function setDemoScreen(screenKey) {
  appState.currentScreen = screenKey;
  
  // Highlight active pill
  document.querySelectorAll('[data-demo-nav]').forEach(btn => {
    if (btn.getAttribute('data-demo-nav') === screenKey) {
      btn.classList.add('bg-amber-500', 'text-white', 'shadow-md', 'shadow-amber-500/20');
      btn.classList.remove('bg-zinc-200', 'dark:bg-zinc-800', 'text-zinc-700', 'dark:text-zinc-300');
    } else {
      btn.classList.remove('bg-amber-500', 'text-white', 'shadow-md', 'shadow-amber-500/20');
      btn.classList.add('bg-zinc-200', 'dark:bg-zinc-800', 'text-zinc-700', 'dark:text-zinc-300');
    }
  });

  renderPhoneDemo();
}

// Dark Mode Toggle
function initTheme() {
  const themeToggle = document.getElementById('theme-toggle');
  const htmlEl = document.documentElement;

  if (appState.isDarkMode) {
    htmlEl.classList.add('dark');
  } else {
    htmlEl.classList.remove('dark');
  }

  if (themeToggle) {
    themeToggle.addEventListener('click', () => {
      appState.isDarkMode = !appState.isDarkMode;
      if (appState.isDarkMode) {
        htmlEl.classList.add('dark');
      } else {
        htmlEl.classList.remove('dark');
      }
      renderPhoneDemo();
    });
  }
}

// FAQ Accordion
function initFaq() {
  document.querySelectorAll('.faq-toggle').forEach(button => {
    button.addEventListener('click', () => {
      const content = button.nextElementSibling;
      const icon = button.querySelector('[data-lucide="chevron-down"]');
      const isOpen = !content.classList.contains('hidden');

      if (isOpen) {
        content.classList.add('hidden');
        if (icon) icon.style.transform = 'rotate(0deg)';
      } else {
        content.classList.remove('hidden');
        if (icon) icon.style.transform = 'rotate(180deg)';
      }
    });
  });
}

// Initialization on DOM loaded
document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  renderPhoneDemo();
  initFaq();

  // Screen selector buttons
  document.querySelectorAll('[data-demo-nav]').forEach(btn => {
    btn.addEventListener('click', () => {
      const screenKey = btn.getAttribute('data-demo-nav');
      setDemoScreen(screenKey);
    });
  });

  if (window.lucide) {
    window.lucide.createIcons();
  }
});
