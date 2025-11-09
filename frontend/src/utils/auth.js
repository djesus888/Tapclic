// ---------- utils/auth.js ----------

// Obtiene el token guardado
function getToken() {
  return localStorage.getItem("token");
}

// Guarda el token
function setToken(token) {
  localStorage.setItem("token", token);
}

// Elimina el token
function clearToken() {
  localStorage.removeItem("token");
}

// Redirige al login (solo si no estamos ya allí)
function redirectToLogin() {
  const path = window.location.pathname;
  if (!path.includes("/login")) {
    clearToken();
    window.location.href = "/login";
  }
}

// Decodifica payload de JWT
function parseJwt(token) {
  try {
    return JSON.parse(atob(token.split(".")[1]));
  } catch {
    return null;
  }
}

// Verifica si el token está expirado
function isTokenExpired(token) {
  const payload = parseJwt(token);
  if (!payload || !payload.exp) return true;
  return Date.now() / 1000 > payload.exp;
}

// Verifica la sesión actual
function checkSession() {
  const token = getToken();
  const path = window.location.pathname;

  if (path.includes("/login")) return; // evita bucle

  if (!token || isTokenExpired(token)) {
    redirectToLogin();
    return false;
  }
  return true;
}

// Llamadas API con verificación automática
async function apiFetch(url, options = {}) {
  const token = getToken();
  if (!token) {
    redirectToLogin();
    return null;
  }

  options.headers = {
    ...options.headers,
    Authorization: `Bearer ${token}`,
    Accept: "application/json",
    "Content-Type": "application/json",
  };

  const response = await fetch(url, options);

  if (response.status === 401) {
    redirectToLogin();
    return null;
  }

  return response.json();
}

// Refresca token si aún es válido
async function refreshToken() {
  const token = getToken();
  const path = window.location.pathname;

  if (!token || path.includes("/login")) return;

  try {
    const data = await apiFetch("/api/auth/refreshToken", { method: "POST" });
    if (data?.success && data.token) setToken(data.token);
  } catch {
    redirectToLogin();
  }
}

// Ejecutar verificación solo si no estamos en /login
document.addEventListener("DOMContentLoaded", () => {
  checkSession();
  // Refrescar token cada 5 minutos solo si hay sesión activa
  if (getToken()) setInterval(refreshToken, 5 * 60 * 1000);
});

// Exportar funciones
export { apiFetch, checkSession, getToken, setToken, clearToken };
