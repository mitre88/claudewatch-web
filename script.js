/**
 * ClaudeWatch Website — Language Switcher & Interactions
 */

// ─── Translations ───────────────────────────────────────────────────────────

const translations = {
  es: {
    // Nav
    nav_features: "Funciones",
    nav_howto: "Cómo funciona",
    nav_privacy: "Privacidad",
    nav_support: "Soporte",

    // Hero
    hero_badge: "Disponible para iPhone",
    hero_title: "Tu Mac. Vigilado desde tu iPhone.",
    hero_app_name: "ClaudeWatch",
    hero_tagline: "Monitorea tus sesiones de Claude Code en tiempo real desde tu iPhone. Recibe notificaciones, controla comandos y permanece al tanto — sin mirar la pantalla de tu Mac.",
    hero_cta_store: "App Store",
    hero_cta_store_sub: "Descarga en el",
    hero_cta_docs: "Ver documentación",

    // Features
    features_label: "Funciones principales",
    features_title: "Todo lo que necesitas a mano",
    features_subtitle: "Diseñado para desarrolladores que usan Claude Code. Una conexión directa entre tu Mac y tu iPhone, sin servidores en la nube.",

    feat1_title: "Monitoreo en tiempo real",
    feat1_desc: "Ve el output de Claude Code directamente en tu iPhone. Cada línea del terminal, sincronizada al instante.",

    feat2_title: "Notificaciones inteligentes",
    feat2_desc: "Recibe alertas cuando una tarea finaliza, cuando Claude espera tu respuesta o cuando ocurre un error.",

    feat3_title: "Dynamic Island",
    feat3_desc: "Seguimiento de sesiones activas en el Dynamic Island del iPhone 14 Pro y posteriores. Siempre visible.",

    feat4_title: "Emparejamiento QR",
    feat4_desc: "Escanea el código QR en tu Mac para emparejar en segundos. Sin configuración compleja.",

    feat5_title: "Bonjour auto-discovery",
    feat5_desc: "Tu iPhone detecta automáticamente el servidor en tu Mac usando Bonjour, como AirDrop.",

    feat6_title: "Sin cuenta. Sin nube.",
    feat6_desc: "Conexión local directa sobre WiFi. Tus datos nunca salen de tu red.",

    feat_terminal_title: "Terminal en tu bolsillo",
    feat_terminal_desc: "Visualiza la salida del terminal con formato de código, colores y scroll. Como tener una ventana de Mac en tu iPhone.",
    feat_terminal_cmd: "$ claude --dangerously-skip-permissions",
    feat_terminal_out1: "✓ Sesión iniciada",
    feat_terminal_out2: "Procesando...",
    feat_terminal_acc: "→ 3 archivos modificados",

    // How it works
    howto_label: "Instalación",
    howto_title: "En marcha en 3 pasos",
    howto_subtitle: "Sin configuración de servidores, sin cuentas, sin VPN. Solo WiFi local.",

    step1_title: "Instala el servidor en tu Mac",
    step1_desc: "Un solo comando instala el servidor ligero que corre en segundo plano en tu Mac.",
    step1_copy: "Copiar",
    step1_copied: "Copiado",

    step2_title: "Escanea el código QR",
    step2_desc: "Abre ClaudeWatch en tu iPhone y escanea el QR que aparece en tu Mac. El emparejamiento es automático.",

    step3_title: "Monitorea desde tu iPhone",
    step3_desc: "Tu iPhone se conecta a tu Mac por WiFi local. Ve las sesiones activas, recibe notificaciones y controla Claude Code.",

    // Privacy
    privacy_label: "Privacidad",
    privacy_title: "Tu privacidad, nuestra prioridad",
    privacy_p1: "ClaudeWatch opera completamente en tu red local. No existe ningún servidor en la nube.",
    priv1: "Conexión solo por WiFi local",
    priv2: "Sin servidores en la nube",
    priv3: "Sin cuentas ni registro",
    priv4: "Sin analytics ni rastreo",
    priv5: "Cámara solo para escanear QR",
    priv6: "Código abierto y auditable",

    // Footer
    footer_tagline: "Monitoreo local para Claude Code",
    footer_privacy: "Política de Privacidad",
    footer_terms: "Términos de Uso",
    footer_support: "Soporte",
    footer_copy: "© 2025 ClaudeWatch. Todos los derechos reservados.",

    // Mock UI
    mock_live: "En vivo",
    mock_sessions: "Sesiones activas",
    mock_tokens: "Tokens",
    mock_di_text: "claude",
  },

  en: {
    nav_features: "Features",
    nav_howto: "How it works",
    nav_privacy: "Privacy",
    nav_support: "Support",

    hero_badge: "Available for iPhone",
    hero_title: "Your Mac. Watched from your iPhone.",
    hero_app_name: "ClaudeWatch",
    hero_tagline: "Monitor your Claude Code sessions in real time from your iPhone. Get notifications, track commands, and stay in the loop — without looking at your Mac screen.",
    hero_cta_store: "App Store",
    hero_cta_store_sub: "Download on the",
    hero_cta_docs: "View documentation",

    features_label: "Key features",
    features_title: "Everything you need at hand",
    features_subtitle: "Built for developers who use Claude Code. A direct connection between your Mac and iPhone — no cloud servers involved.",

    feat1_title: "Real-time monitoring",
    feat1_desc: "Watch Claude Code output directly on your iPhone. Every terminal line, synced instantly.",

    feat2_title: "Smart notifications",
    feat2_desc: "Get alerts when a task finishes, when Claude waits for your response, or when an error occurs.",

    feat3_title: "Dynamic Island",
    feat3_desc: "Active session tracking in the Dynamic Island on iPhone 14 Pro and later. Always visible.",

    feat4_title: "QR pairing",
    feat4_desc: "Scan the QR code on your Mac to pair in seconds. No complex setup required.",

    feat5_title: "Bonjour auto-discovery",
    feat5_desc: "Your iPhone automatically finds the server on your Mac using Bonjour, just like AirDrop.",

    feat6_title: "No account. No cloud.",
    feat6_desc: "Direct local connection over WiFi. Your data never leaves your network.",

    feat_terminal_title: "Terminal in your pocket",
    feat_terminal_desc: "View terminal output with code formatting, colors, and scroll. Like having a Mac window on your iPhone.",
    feat_terminal_cmd: "$ claude --dangerously-skip-permissions",
    feat_terminal_out1: "✓ Session started",
    feat_terminal_out2: "Processing...",
    feat_terminal_acc: "→ 3 files modified",

    howto_label: "Setup",
    howto_title: "Up and running in 3 steps",
    howto_subtitle: "No server configuration, no accounts, no VPN. Just local WiFi.",

    step1_title: "Install the server on your Mac",
    step1_desc: "A single command installs the lightweight server that runs in the background on your Mac.",
    step1_copy: "Copy",
    step1_copied: "Copied",

    step2_title: "Scan the QR code",
    step2_desc: "Open ClaudeWatch on your iPhone and scan the QR displayed on your Mac. Pairing is automatic.",

    step3_title: "Monitor from your iPhone",
    step3_desc: "Your iPhone connects to your Mac over local WiFi. View active sessions, get notifications, and control Claude Code.",

    privacy_label: "Privacy",
    privacy_title: "Your privacy, our priority",
    privacy_p1: "ClaudeWatch runs entirely on your local network. There is no cloud server.",
    priv1: "Local WiFi connection only",
    priv2: "No cloud servers",
    priv3: "No accounts or sign-up",
    priv4: "No analytics or tracking",
    priv5: "Camera used only for QR scanning",
    priv6: "Open source and auditable",

    footer_tagline: "Local monitoring for Claude Code",
    footer_privacy: "Privacy Policy",
    footer_terms: "Terms of Use",
    footer_support: "Support",
    footer_copy: "© 2025 ClaudeWatch. All rights reserved.",

    mock_live: "Live",
    mock_sessions: "Active sessions",
    mock_tokens: "Tokens",
    mock_di_text: "claude",
  },

  fr: {
    nav_features: "Fonctionnalités",
    nav_howto: "Comment ça marche",
    nav_privacy: "Confidentialité",
    nav_support: "Support",

    hero_badge: "Disponible pour iPhone",
    hero_title: "Votre Mac. Surveillé depuis votre iPhone.",
    hero_app_name: "ClaudeWatch",
    hero_tagline: "Surveillez vos sessions Claude Code en temps réel depuis votre iPhone. Recevez des notifications, suivez les commandes et restez informé — sans regarder l'écran de votre Mac.",
    hero_cta_store: "App Store",
    hero_cta_store_sub: "Télécharger sur l'",
    hero_cta_docs: "Voir la documentation",

    features_label: "Fonctionnalités clés",
    features_title: "Tout ce dont vous avez besoin",
    features_subtitle: "Conçu pour les développeurs qui utilisent Claude Code. Une connexion directe entre votre Mac et votre iPhone, sans serveurs cloud.",

    feat1_title: "Surveillance en temps réel",
    feat1_desc: "Voyez la sortie de Claude Code directement sur votre iPhone. Chaque ligne du terminal, synchronisée instantanément.",

    feat2_title: "Notifications intelligentes",
    feat2_desc: "Recevez des alertes quand une tâche se termine, quand Claude attend votre réponse ou quand une erreur survient.",

    feat3_title: "Dynamic Island",
    feat3_desc: "Suivi des sessions actives dans le Dynamic Island de l'iPhone 14 Pro et suivants. Toujours visible.",

    feat4_title: "Jumelage QR",
    feat4_desc: "Scannez le code QR sur votre Mac pour jumeler en quelques secondes. Aucune configuration complexe.",

    feat5_title: "Découverte automatique Bonjour",
    feat5_desc: "Votre iPhone détecte automatiquement le serveur sur votre Mac via Bonjour, comme AirDrop.",

    feat6_title: "Sans compte. Sans cloud.",
    feat6_desc: "Connexion locale directe via WiFi. Vos données ne quittent jamais votre réseau.",

    feat_terminal_title: "Terminal dans votre poche",
    feat_terminal_desc: "Visualisez la sortie du terminal avec formatage de code, couleurs et défilement. Comme avoir une fenêtre Mac sur votre iPhone.",
    feat_terminal_cmd: "$ claude --dangerously-skip-permissions",
    feat_terminal_out1: "✓ Session démarrée",
    feat_terminal_out2: "Traitement en cours...",
    feat_terminal_acc: "→ 3 fichiers modifiés",

    howto_label: "Installation",
    howto_title: "Opérationnel en 3 étapes",
    howto_subtitle: "Sans configuration de serveur, sans compte, sans VPN. Seulement le WiFi local.",

    step1_title: "Installez le serveur sur votre Mac",
    step1_desc: "Une seule commande installe le serveur léger qui tourne en arrière-plan sur votre Mac.",
    step1_copy: "Copier",
    step1_copied: "Copié",

    step2_title: "Scannez le code QR",
    step2_desc: "Ouvrez ClaudeWatch sur votre iPhone et scannez le QR affiché sur votre Mac. Le jumelage est automatique.",

    step3_title: "Surveillez depuis votre iPhone",
    step3_desc: "Votre iPhone se connecte à votre Mac via le WiFi local. Voyez les sessions actives, recevez des notifications et contrôlez Claude Code.",

    privacy_label: "Confidentialité",
    privacy_title: "Votre vie privée, notre priorité",
    privacy_p1: "ClaudeWatch fonctionne entièrement sur votre réseau local. Il n'y a pas de serveur cloud.",
    priv1: "Connexion WiFi locale uniquement",
    priv2: "Aucun serveur cloud",
    priv3: "Aucun compte requis",
    priv4: "Aucune analyse ni traçage",
    priv5: "Caméra uniquement pour scanner le QR",
    priv6: "Open source et auditable",

    footer_tagline: "Surveillance locale pour Claude Code",
    footer_privacy: "Politique de confidentialité",
    footer_terms: "Conditions d'utilisation",
    footer_support: "Support",
    footer_copy: "© 2025 ClaudeWatch. Tous droits réservés.",

    mock_live: "En direct",
    mock_sessions: "Sessions actives",
    mock_tokens: "Tokens",
    mock_di_text: "claude",
  }
};

// ─── Language Switch ─────────────────────────────────────────────────────────

let currentLang = localStorage.getItem('cw_lang') || 'es';

function setLanguage(lang) {
  currentLang = lang;
  localStorage.setItem('cw_lang', lang);

  // Update buttons
  document.querySelectorAll('.lang-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.lang === lang);
  });

  // Update all translated elements
  const t = translations[lang];
  if (!t) return;

  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.dataset.i18n;
    if (t[key] !== undefined) {
      el.textContent = t[key];
    }
  });

  // Update html lang attribute
  document.documentElement.lang = lang;
}

// ─── Copy Command ────────────────────────────────────────────────────────────

function copyInstallCommand() {
  const cmd = 'bash <(curl -sL https://claudewatch.app/install.sh)';
  navigator.clipboard.writeText(cmd).then(() => {
    const btn = document.getElementById('copy-btn');
    if (btn) {
      const t = translations[currentLang];
      btn.textContent = t.step1_copied || 'Copied';
      btn.classList.add('copied');
      setTimeout(() => {
        btn.textContent = t.step1_copy || 'Copy';
        btn.classList.remove('copied');
      }, 2000);
    }
  }).catch(() => {
    // fallback for older browsers
    const el = document.createElement('textarea');
    el.value = cmd;
    el.style.position = 'absolute';
    el.style.left = '-9999px';
    document.body.appendChild(el);
    el.select();
    document.execCommand('copy');
    document.body.removeChild(el);
  });
}

// ─── FAQ Accordion ───────────────────────────────────────────────────────────

function initFAQ() {
  document.querySelectorAll('.faq-question').forEach(btn => {
    btn.addEventListener('click', () => {
      const item = btn.closest('.faq-item');
      const wasOpen = item.classList.contains('open');

      // Close all
      document.querySelectorAll('.faq-item.open').forEach(i => i.classList.remove('open'));

      // Toggle clicked
      if (!wasOpen) {
        item.classList.add('open');
      }
    });
  });
}

// ─── Scroll-based nav shadow ─────────────────────────────────────────────────

function initScrollEffects() {
  const nav = document.querySelector('.nav');
  if (!nav) return;

  window.addEventListener('scroll', () => {
    if (window.scrollY > 10) {
      nav.style.boxShadow = '0 1px 24px rgba(0,0,0,0.5)';
    } else {
      nav.style.boxShadow = 'none';
    }
  }, { passive: true });
}

// ─── Init ────────────────────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {
  // Language switcher buttons
  document.querySelectorAll('.lang-btn').forEach(btn => {
    btn.addEventListener('click', () => setLanguage(btn.dataset.lang));
  });

  // Apply saved language
  setLanguage(currentLang);

  // Copy button
  const copyBtn = document.getElementById('copy-btn');
  if (copyBtn) {
    copyBtn.addEventListener('click', copyInstallCommand);
  }

  // FAQ
  initFAQ();

  // Scroll effects
  initScrollEffects();
});
