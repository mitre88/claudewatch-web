/**
 * ClaudeWatch — Terminal Aesthetic Scripts
 * Matrix rain, typing animation, language switcher, interactions
 */

// ─── Translations ─────────────────────────────────────────────────────────────

const translations = {
  es: {
    nav_features: "Funciones",
    nav_howto: "Cómo funciona",
    nav_privacy: "Privacidad",
    nav_support: "Soporte",

    hero_badge: "$ disponible --plataforma iPhone",
    hero_line1: "Monitorea Claude Code",
    hero_line2_pre: "desde tu",
    hero_line2_word: " iPhone.",
    hero_tagline: "Monitoreo en tiempo real por WiFi local. Sin nube, sin cuentas, sin compromisos.",
    hero_cta_store: "App Store",
    hero_cta_docs: "Ver docs",

    stat1: "Latencia local",
    stat2: "Privado, sin nube",
    stat3: "Conexión directa",
    stat4: "Requerido",

    features_label: "$ features --list",
    features_title: "Todo lo que necesitas a mano",
    features_subtitle: "Diseñado para desarrolladores que usan Claude Code. Conexión local directa, sin servidores en la nube.",

    feat_terminal_title: "Terminal en tu bolsillo",
    feat_terminal_desc: "Visualiza el output de Claude Code con formato de código, colores y scroll. Como una ventana Mac en tu iPhone.",
    feat_terminal_cmd: "claude --dangerously-skip-permissions",
    feat_terminal_out1: "Sesión iniciada",
    feat_terminal_acc: "3 archivos modificados",

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

    preview_label: "$ app --screenshots",
    preview_title: "Vélo en acción",
    preview_cap1: "// Terminal Remoto",
    preview_cap2: "// Conectar y Emparejar",
    preview_cap3: "// Sesiones Activas",
    preview_cap4: "// Configuración",

    howto_label: "$ setup --help",
    howto_title: "En marcha en 3 pasos",
    howto_subtitle: "Sin configuración de servidores, sin cuentas, sin VPN. Solo WiFi local.",

    step1_title: "Instala el servidor en tu Mac",
    step1_desc: "Un solo comando instala el servidor ligero que corre en segundo plano en tu Mac.",
    step1_copy: "copiar",
    step1_copied: "copiado",

    step2_title: "Escanea el código QR",
    step2_desc: "Abre ClaudeWatch en tu iPhone y escanea el QR que aparece en tu Mac. El emparejamiento es automático.",

    step3_title: "Monitorea desde tu iPhone",
    step3_desc: "Tu iPhone se conecta a tu Mac por WiFi local. Ve las sesiones activas, recibe notificaciones y controla Claude Code.",
    step3_s1: "claudewatch-web — EJECUTANDO",
    step3_s2: "iOS-app build — ESPERANDO",
    step3_s3: "rediseño — COMPLETADO",

    privacy_label: "$ privacy --status",
    privacy_title: "Tu privacidad, nuestra prioridad",
    privacy_p1: "ClaudeWatch opera completamente en tu red local. No existe ningún servidor en la nube.",
    priv1: "SOLO_WIFI_LOCAL",
    priv1_desc: "Conexión solo en tu red local",
    priv2: "SIN_NUBE",
    priv2_desc: "Sin servidores cloud, sin almacenamiento remoto",
    priv3: "SIN_CUENTA",
    priv3_desc: "Sin registro ni autenticación",
    priv4: "SIN_ANALYTICS",
    priv4_desc: "Cero rastreo ni analíticas",
    priv5: "CAMARA_SOLO_QR",
    priv5_desc: "Cámara solo para escanear QR",
    priv6: "CODIGO_ABIERTO",
    priv6_desc: "Código visible y auditable",

    nav_pricing: "Precios",

    pricing_label: "$ pricing --plans",
    pricing_title: "Empieza Gratis, Pasa a Pro",
    pricing_subtitle: "Prueba ClaudeWatch gratis por 5 dias. Luego elige el plan que mejor te funcione.",
    pricing_monthly_title: "Mensual",
    pricing_monthly_period: "/mes",
    pricing_annual_title: "Anual",
    pricing_annual_period: "/anio",
    pricing_annual_badge: "Mejor Valor",
    pricing_annual_subtext: "$2.00/mes — Ahorra vs mensual",
    pricing_lifetime_title: "De por Vida",
    pricing_lifetime_badge: "Para Siempre",
    pricing_lifetime_subtext: "Pago unico",
    pricing_feat_pro: "Todas las funciones Pro",
    pricing_feat_cancel: "Cancela cuando quieras",
    pricing_feat_monitor: "Acceso completo al monitoreo",
    pricing_feat_free_months: "2 meses gratis",
    pricing_feat_no_renewals: "Sin renovaciones",
    pricing_feat_lifetime_updates: "Actualizaciones de por vida",
    pricing_cta: "Iniciar Prueba Gratis",
    pricing_disclaimer: "Prueba gratuita de 5 dias en todos los planes. No se requiere tarjeta de credito.",

    footer_tagline: "// Monitoreo local para Claude Code",
    footer_privacy: "Privacidad",
    footer_terms: "Términos",
    footer_support: "Soporte",
    footer_copy: "© 2025 ClaudeWatch. Todos los derechos reservados.",
  },

  en: {
    nav_features: "Features",
    nav_howto: "How it works",
    nav_privacy: "Privacy",
    nav_support: "Support",

    hero_badge: "$ available --platform iPhone",
    hero_line1: "Monitor Claude Code",
    hero_line2_pre: "from your",
    hero_line2_word: " iPhone.",
    hero_tagline: "Real-time monitoring over local WiFi. No cloud, no accounts, no compromise.",
    hero_cta_store: "App Store",
    hero_cta_docs: "View docs",

    stat1: "Local latency",
    stat2: "Private, no cloud",
    stat3: "Direct connection",
    stat4: "Required",

    features_label: "$ features --list",
    features_title: "Everything you need at hand",
    features_subtitle: "Built for developers who use Claude Code. A direct local connection, no cloud servers involved.",

    feat_terminal_title: "Terminal in your pocket",
    feat_terminal_desc: "View Claude Code output with code formatting, colors, and scroll. Like a Mac window on your iPhone.",
    feat_terminal_cmd: "claude --dangerously-skip-permissions",
    feat_terminal_out1: "Session started",
    feat_terminal_acc: "3 files modified",

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

    preview_label: "$ app --screenshots",
    preview_title: "See it in action",
    preview_cap1: "// Remote Terminal",
    preview_cap2: "// Connect & Pair",
    preview_cap3: "// Active Sessions",
    preview_cap4: "// Settings",

    howto_label: "$ setup --help",
    howto_title: "Up and running in 3 steps",
    howto_subtitle: "No server config, no accounts, no VPN. Just local WiFi.",

    step1_title: "Install the server on your Mac",
    step1_desc: "A single command installs the lightweight background server on your Mac.",
    step1_copy: "copy",
    step1_copied: "copied",

    step2_title: "Scan the QR code",
    step2_desc: "Open ClaudeWatch on your iPhone and scan the QR displayed on your Mac. Pairing is automatic.",

    step3_title: "Monitor from your iPhone",
    step3_desc: "Your iPhone connects to your Mac over local WiFi. View active sessions, get notifications, and control Claude Code.",
    step3_s1: "claudewatch-web — RUNNING",
    step3_s2: "iOS-app build — WAITING",
    step3_s3: "redesign — COMPLETE",

    privacy_label: "$ privacy --status",
    privacy_title: "Your privacy, our priority",
    privacy_p1: "ClaudeWatch runs entirely on your local network. There is no cloud server.",
    priv1: "LOCAL_WIFI_ONLY",
    priv1_desc: "Connection only over your local network",
    priv2: "NO_CLOUD",
    priv2_desc: "No cloud servers, no remote storage",
    priv3: "NO_ACCOUNT",
    priv3_desc: "No sign-up, no registration required",
    priv4: "NO_ANALYTICS",
    priv4_desc: "Zero tracking or analytics",
    priv5: "CAMERA_QR_ONLY",
    priv5_desc: "Camera used only for QR scanning",
    priv6: "OPEN_SOURCE",
    priv6_desc: "Code is open and auditable",

    nav_pricing: "Pricing",

    pricing_label: "$ pricing --plans",
    pricing_title: "Start Free, Go Pro",
    pricing_subtitle: "Try ClaudeWatch free for 5 days. Then choose the plan that works for you.",
    pricing_monthly_title: "Monthly",
    pricing_monthly_period: "/mo",
    pricing_annual_title: "Annual",
    pricing_annual_period: "/yr",
    pricing_annual_badge: "Best Value",
    pricing_annual_subtext: "$2.00/mo — Save vs monthly",
    pricing_lifetime_title: "Lifetime",
    pricing_lifetime_badge: "Forever",
    pricing_lifetime_subtext: "One-time payment",
    pricing_feat_pro: "All Pro features",
    pricing_feat_cancel: "Cancel anytime",
    pricing_feat_monitor: "Full monitoring access",
    pricing_feat_free_months: "2 months free",
    pricing_feat_no_renewals: "No renewals ever",
    pricing_feat_lifetime_updates: "Lifetime updates",
    pricing_cta: "Start Free Trial",
    pricing_disclaimer: "5-day free trial for all plans. No credit card required to start.",

    footer_tagline: "// Local monitoring for Claude Code",
    footer_privacy: "Privacy Policy",
    footer_terms: "Terms",
    footer_support: "Support",
    footer_copy: "© 2025 ClaudeWatch. All rights reserved.",
  },

  fr: {
    nav_features: "Fonctionnalités",
    nav_howto: "Comment ça marche",
    nav_privacy: "Confidentialité",
    nav_support: "Support",

    hero_badge: "$ disponible --plateforme iPhone",
    hero_line1: "Surveillez Claude Code",
    hero_line2_pre: "depuis votre",
    hero_line2_word: " iPhone.",
    hero_tagline: "Surveillance en temps réel via WiFi local. Pas de cloud, pas de compte, sans compromis.",
    hero_cta_store: "App Store",
    hero_cta_docs: "Voir les docs",

    stat1: "Latence locale",
    stat2: "Privé, sans cloud",
    stat3: "Connexion directe",
    stat4: "Requis",

    features_label: "$ features --list",
    features_title: "Tout ce dont vous avez besoin",
    features_subtitle: "Conçu pour les développeurs qui utilisent Claude Code. Connexion locale directe, sans serveurs cloud.",

    feat_terminal_title: "Terminal dans votre poche",
    feat_terminal_desc: "Visualisez la sortie de Claude Code avec formatage de code, couleurs et défilement. Comme une fenêtre Mac sur votre iPhone.",
    feat_terminal_cmd: "claude --dangerously-skip-permissions",
    feat_terminal_out1: "Session démarrée",
    feat_terminal_acc: "3 fichiers modifiés",

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

    preview_label: "$ app --screenshots",
    preview_title: "Voir en action",
    preview_cap1: "// Terminal à distance",
    preview_cap2: "// Connexion & Jumelage",
    preview_cap3: "// Sessions actives",
    preview_cap4: "// Paramètres",

    howto_label: "$ setup --help",
    howto_title: "Opérationnel en 3 étapes",
    howto_subtitle: "Sans configuration de serveur, sans compte, sans VPN. Seulement le WiFi local.",

    step1_title: "Installez le serveur sur votre Mac",
    step1_desc: "Une seule commande installe le serveur léger qui tourne en arrière-plan sur votre Mac.",
    step1_copy: "copier",
    step1_copied: "copié",

    step2_title: "Scannez le code QR",
    step2_desc: "Ouvrez ClaudeWatch sur votre iPhone et scannez le QR affiché sur votre Mac. Le jumelage est automatique.",

    step3_title: "Surveillez depuis votre iPhone",
    step3_desc: "Votre iPhone se connecte à votre Mac via le WiFi local. Voyez les sessions actives, recevez des notifications et contrôlez Claude Code.",
    step3_s1: "claudewatch-web — EN COURS",
    step3_s2: "iOS-app build — EN ATTENTE",
    step3_s3: "refonte — TERMINÉ",

    privacy_label: "$ privacy --status",
    privacy_title: "Votre vie privée, notre priorité",
    privacy_p1: "ClaudeWatch fonctionne entièrement sur votre réseau local. Il n'y a pas de serveur cloud.",
    priv1: "WIFI_LOCAL_SEULEMENT",
    priv1_desc: "Connexion uniquement sur votre réseau local",
    priv2: "SANS_CLOUD",
    priv2_desc: "Aucun serveur cloud, aucun stockage distant",
    priv3: "SANS_COMPTE",
    priv3_desc: "Aucune inscription requise",
    priv4: "SANS_ANALYTICS",
    priv4_desc: "Zéro traçage ni analytiques",
    priv5: "CAMERA_QR_SEULEMENT",
    priv5_desc: "Caméra uniquement pour scanner le QR",
    priv6: "CODE_OUVERT",
    priv6_desc: "Code visible et auditable",

    nav_pricing: "Tarifs",

    pricing_label: "$ pricing --plans",
    pricing_title: "Commencez Gratuitement, Passez Pro",
    pricing_subtitle: "Essayez ClaudeWatch gratuitement pendant 5 jours. Puis choisissez le plan qui vous convient.",
    pricing_monthly_title: "Mensuel",
    pricing_monthly_period: "/mois",
    pricing_annual_title: "Annuel",
    pricing_annual_period: "/an",
    pricing_annual_badge: "Meilleur Rapport",
    pricing_annual_subtext: "2,00 $/mois — Economisez vs mensuel",
    pricing_lifetime_title: "A Vie",
    pricing_lifetime_badge: "Pour Toujours",
    pricing_lifetime_subtext: "Paiement unique",
    pricing_feat_pro: "Toutes les fonctionnalites Pro",
    pricing_feat_cancel: "Annulez a tout moment",
    pricing_feat_monitor: "Acces complet au monitoring",
    pricing_feat_free_months: "2 mois gratuits",
    pricing_feat_no_renewals: "Aucun renouvellement",
    pricing_feat_lifetime_updates: "Mises a jour a vie",
    pricing_cta: "Essai Gratuit",
    pricing_disclaimer: "Essai gratuit de 5 jours pour tous les plans. Aucune carte de credit requise.",

    footer_tagline: "// Surveillance locale pour Claude Code",
    footer_privacy: "Politique de confidentialité",
    footer_terms: "Conditions",
    footer_support: "Support",
    footer_copy: "© 2025 ClaudeWatch. Tous droits réservés.",
  }
};

// ─── Matrix Rain ──────────────────────────────────────────────────────────────

function initMatrixRain() {
  const canvas = document.getElementById('matrix-canvas');
  if (!canvas) return;

  const ctx = canvas.getContext('2d');
  const chars = '01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン'.split('');
  let cols, drops;
  const fontSize = 13;

  function resize() {
    canvas.width  = window.innerWidth;
    canvas.height = window.innerHeight;
    cols  = Math.floor(canvas.width / fontSize);
    drops = Array(cols).fill(1);
  }

  resize();
  window.addEventListener('resize', resize, { passive: true });

  function draw() {
    ctx.fillStyle = 'rgba(13, 17, 23, 0.05)';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    ctx.font = `${fontSize}px "Roboto Mono", monospace`;

    for (let i = 0; i < drops.length; i++) {
      // Mix green and orange chars
      const useOrange = Math.random() < 0.1;
      ctx.fillStyle = useOrange ? '#FF9A1F' : '#39D353';
      const char = chars[Math.floor(Math.random() * chars.length)];
      ctx.fillText(char, i * fontSize, drops[i] * fontSize);

      if (drops[i] * fontSize > canvas.height && Math.random() > 0.975) {
        drops[i] = 0;
      }
      drops[i]++;
    }
  }

  setInterval(draw, 50);
}

// ─── Typing Animation ─────────────────────────────────────────────────────────

function initTypingAnimation(text) {
  const el = document.getElementById('typing-target');
  if (!el) return;

  el.textContent = '';
  let i = 0;

  function type() {
    if (i < text.length) {
      el.textContent += text[i++];
      setTimeout(type, 28 + Math.random() * 20);
    }
  }

  setTimeout(type, 800);
}

// ─── Language Switch ──────────────────────────────────────────────────────────

let currentLang = localStorage.getItem('cw_lang') || 'es';

function setLanguage(lang) {
  currentLang = lang;
  localStorage.setItem('cw_lang', lang);

  document.querySelectorAll('.lang-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.lang === lang);
  });

  const t = translations[lang];
  if (!t) return;

  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.dataset.i18n;
    if (t[key] !== undefined) {
      el.textContent = t[key];
    }
  });

  document.documentElement.lang = lang;

  // Re-run typing animation with translated text
  if (t.hero_tagline) {
    initTypingAnimation(t.hero_tagline);
  }

  // Update copy button state
  const copyBtn = document.getElementById('copy-btn');
  if (copyBtn) {
    copyBtn.textContent = t.step1_copy || 'copy';
  }
}

// ─── Copy Command ─────────────────────────────────────────────────────────────

function copyInstallCommand() {
  const cmd = 'bash <(curl -sL https://claudewatch.app/install.sh)';
  const btn = document.getElementById('copy-btn');

  navigator.clipboard.writeText(cmd).then(() => {
    if (btn) {
      const t = translations[currentLang];
      btn.textContent = t.step1_copied || 'copied!';
      btn.classList.add('copied');
      setTimeout(() => {
        btn.textContent = t.step1_copy || 'copy';
        btn.classList.remove('copied');
      }, 2000);
    }
  }).catch(() => {
    const el = document.createElement('textarea');
    el.value = cmd;
    el.style.cssText = 'position:fixed;left:-9999px;top:-9999px';
    document.body.appendChild(el);
    el.select();
    document.execCommand('copy');
    document.body.removeChild(el);
  });
}

// ─── FAQ Accordion ────────────────────────────────────────────────────────────

function initFAQ() {
  document.querySelectorAll('.faq-question').forEach(btn => {
    btn.addEventListener('click', () => {
      const item = btn.closest('.faq-item');
      const wasOpen = item.classList.contains('open');
      document.querySelectorAll('.faq-item.open').forEach(i => i.classList.remove('open'));
      if (!wasOpen) item.classList.add('open');
    });
  });
}

// ─── Scroll Effects ───────────────────────────────────────────────────────────

function initScrollEffects() {
  const nav = document.querySelector('.nav');
  if (!nav) return;

  window.addEventListener('scroll', () => {
    if (window.scrollY > 10) {
      nav.style.boxShadow = '0 1px 0 rgba(255,255,255,0.04), 0 4px 24px rgba(0,0,0,0.6)';
    } else {
      nav.style.boxShadow = 'none';
    }
  }, { passive: true });
}

// ─── Intersection Observer for subtle animations ──────────────────────────────
// Cards are always visible (opacity:1 in CSS). JS only adds a subtle lift
// animation via a class — so if the observer never fires, cards still show.

function initScrollReveal() {
  if (!window.IntersectionObserver) return;

  const cards = document.querySelectorAll('.feature-card, .step, .screenshot-item, .pricing-card, .section-header');
  if (!cards.length) return;

  const io = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('revealed');
        io.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });

  cards.forEach((card, index) => {
    card.classList.add('reveal-ready');
    card.setAttribute('data-delay', ((index % 6) + 1).toString());
    io.observe(card);
  });
}

// ─── Floating Particles ────────────────────────────────────────────────────────

function initParticles() {
  const container = document.querySelector('.particles-container');
  if (!container) return;

  const particleCount = 15;

  for (let i = 0; i < particleCount; i++) {
    const particle = document.createElement('div');
    particle.className = `particle particle--${Math.random() > 0.5 ? 'green' : 'orange'}`;
    
    // Randomize position and animation
    particle.style.left = `${Math.random() * 100}%`;
    particle.style.animationDelay = `${Math.random() * 20}s`;
    particle.style.animationDuration = `${15 + Math.random() * 10}s`;
    
    // Random size
    const size = 2 + Math.random() * 4;
    particle.style.width = `${size}px`;
    particle.style.height = `${size}px`;
    
    container.appendChild(particle);
  }
}

// ─── Init ─────────────────────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {
  // Matrix rain (hero only)
  if (document.getElementById('matrix-canvas')) {
    initMatrixRain();
  }

  // Floating particles
  initParticles();

  // Language switcher
  document.querySelectorAll('.lang-btn').forEach(btn => {
    btn.addEventListener('click', () => setLanguage(btn.dataset.lang));
  });
  setLanguage(currentLang);

  // Copy button
  const copyBtn = document.getElementById('copy-btn');
  if (copyBtn) copyBtn.addEventListener('click', copyInstallCommand);

  // FAQ
  initFAQ();

  // Scroll effects
  initScrollEffects();

  // Reveal animations
  initScrollReveal();
});
