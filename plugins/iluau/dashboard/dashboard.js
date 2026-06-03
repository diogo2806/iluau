async function getState() {
  const res = await fetch("/api/state");
  return res.json();
}

async function getJobs() {
  const res = await fetch("/api/jobs");
  return res.json();
}

function formatTime(value) {
  if (!value) return "-";
  return new Date(value).toLocaleString();
}

function setPanel(name) {
  document.querySelectorAll(".menu-item").forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.panel === name);
  });
  document.querySelectorAll(".panel").forEach((panel) => {
    panel.classList.add("hidden");
  });
  const visible = document.getElementById(`panel-${name}`);
  if (visible) visible.classList.remove("hidden");
}

function renderJobs(jobs) {
  const list = document.getElementById("jobsList");
  list.innerHTML = "";
  jobs.forEach((job) => {
    const el = document.createElement("div");
    el.className = "job";
    el.innerHTML = `
      <div class="job-top">
        <strong>${job.type}</strong>
        <span>${job.status}</span>
      </div>
      <div class="muted">${job.id}</div>
      <pre>${JSON.stringify(job.payload, null, 2)}</pre>
    `;
    list.appendChild(el);
  });
}

async function refresh() {
  const state = await getState();
  document.getElementById("dashboardUrl").textContent = `http://127.0.0.1:${state.dashboardPort}/`;
  document.getElementById("dashboardPort").textContent = String(state.dashboardPort);
  document.getElementById("serverVersion").textContent = state.version;
  document.getElementById("serverStarted").textContent = `Started ${formatTime(state.runtime.startedAt)}`;
  document.getElementById("bridgeState").textContent = state.bridge.connected ? "connected" : "disconnected";
  document.getElementById("bridgeSeen").textContent = state.bridge.lastHeartbeatAt ? `Last seen ${formatTime(state.bridge.lastHeartbeatAt)}` : "No heartbeat yet";
  document.getElementById("bridgeBadge").textContent = state.bridge.connected ? "bridge online" : "bridge offline";
  document.getElementById("bridgeJson").textContent = JSON.stringify(state.bridge, null, 2);
  document.getElementById("jobsCount").textContent = String(state.jobs.length);
  const jobs = await getJobs();
  renderJobs(jobs.jobs);
}

document.querySelectorAll(".menu-item").forEach((btn) => {
  btn.addEventListener("click", () => setPanel(btn.dataset.panel));
});

document.getElementById("refreshJobs").addEventListener("click", () => refresh());

document.getElementById("jobForm").addEventListener("submit", async (event) => {
  event.preventDefault();
  const form = new FormData(event.currentTarget);
  let payload = {};
  const raw = String(form.get("payload") || "").trim();
  if (raw) {
    payload = JSON.parse(raw);
  }
  await fetch("/api/jobs", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      type: String(form.get("type") || "").trim(),
      payload,
    }),
  });
  event.currentTarget.reset();
  await refresh();
});

refresh();
setInterval(refresh, 3000);
