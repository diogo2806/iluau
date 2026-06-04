const { randomUUID } = require("node:crypto");

const state = {
  pluginName: "iLuau",
  version: "0.4.0+codex.20260603131807",
  dashboardPort: Number(process.env.ILUAU_DASHBOARD_PORT || 3099),
  bridge: {
    connected: false,
    clientId: null,
    clientName: null,
    placeId: null,
    placeName: null,
    lastHeartbeatAt: null,
    lastResultAt: null,
    lastError: null,
  },
  runtime: {
    startedAt: new Date().toISOString(),
    lastPingAt: null,
  },
  jobs: [],
  chat: [],
};

const waiters = new Map();
const MAX_CHAT_MESSAGES = 200;

function nowIso() {
  return new Date().toISOString();
}

function addChatMessage(role, text) {
  const message = {
    id: randomUUID(),
    role: role === "assistant" ? "assistant" : "user",
    text: String(text == null ? "" : text),
    status: role === "assistant" ? "done" : "pending",
    createdAt: nowIso(),
  };
  state.chat.push(message);
  if (state.chat.length > MAX_CHAT_MESSAGES) {
    state.chat.splice(0, state.chat.length - MAX_CHAT_MESSAGES);
  }
  return message;
}

function getChatMessages(limit) {
  const count = Number.isFinite(limit) && limit > 0 ? limit : 50;
  return state.chat.slice(-count);
}

function takePendingChatPrompts() {
  const pending = state.chat.filter((m) => m.role === "user" && m.status === "pending");
  for (const message of pending) {
    message.status = "delivered";
  }
  return pending.map((m) => ({ id: m.id, text: m.text, createdAt: m.createdAt }));
}

function queueJob(type, payload = {}) {
  const job = {
    id: randomUUID(),
    type,
    payload,
    status: "queued",
    createdAt: nowIso(),
    updatedAt: nowIso(),
    result: null,
    error: null,
  };

  state.jobs.unshift(job);
  return job;
}

function waitForJobResult(jobId, timeoutMs = 30000) {
  const job = state.jobs.find((item) => item.id === jobId);
  if (!job) {
    return Promise.reject(new Error(`Unknown job: ${jobId}`));
  }
  if (job.status === "done") {
    return Promise.resolve(job);
  }
  if (job.status === "failed") {
    return Promise.reject(new Error(job.error || "Job failed"));
  }

  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      waiters.delete(jobId);
      reject(new Error(`Timed out waiting for bridge job ${jobId}`));
    }, timeoutMs);

    waiters.set(jobId, {
      resolve: (value) => {
        clearTimeout(timeout);
        resolve(value);
      },
      reject: (error) => {
        clearTimeout(timeout);
        reject(error);
      },
    });
  });
}

function getNextPendingJob(clientId) {
  return state.jobs.find((job) => job.status === "queued" && (!clientId || job.clientId == null || job.clientId === clientId)) || null;
}

function markBridgeHeartbeat(details) {
  state.bridge.connected = true;
  state.bridge.clientId = details.clientId || state.bridge.clientId || randomUUID();
  state.bridge.clientName = details.clientName || state.bridge.clientName || "Roblox Studio";
  state.bridge.placeId = details.placeId ?? state.bridge.placeId;
  state.bridge.placeName = details.placeName ?? state.bridge.placeName;
  state.bridge.lastHeartbeatAt = nowIso();
  state.bridge.lastError = null;
  return state.bridge.clientId;
}

function markJobCompleted(jobId, result, error) {
  const job = state.jobs.find((item) => item.id === jobId);
  if (!job) return null;
  job.status = error ? "failed" : "done";
  job.updatedAt = nowIso();
  job.result = result ?? null;
  job.error = error ?? null;
  state.bridge.lastResultAt = nowIso();
  state.bridge.lastError = error ?? null;
  const waiter = waiters.get(jobId);
  if (waiter) {
    waiters.delete(jobId);
    if (error) {
      waiter.reject(new Error(error));
    } else {
      waiter.resolve(job);
    }
  }
  return job;
}

function getPublicState() {
  return {
    pluginName: state.pluginName,
    version: state.version,
    dashboardPort: state.dashboardPort,
    runtime: state.runtime,
    bridge: state.bridge,
    jobs: state.jobs.slice(0, 25),
  };
}

function getCapabilities() {
  return {
    transport: ["mcp-stdio", "local-http-dashboard", "roblox-plugin-heartbeat"],
    mcpTools: [
      "iluau.ping",
      "iluau.status",
      "iluau.capabilities",
      "iluau.inspect_selection",
      "iluau.get_properties",
      "iluau.get_attributes",
      "iluau.set_attributes",
      "iluau.get_tags",
      "iluau.set_tags",
      "iluau.set_property",
      "iluau.set_properties",
      "iluau.create_instance",
      "iluau.delete_instance",
      "iluau.sync_snapshot",
      "iluau.get_tree",
      "iluau.run_luau",
      "iluau.dashboard_url",
      "iluau.queue_job",
      "iluau.list_jobs",
      "iluau.bridge_state",
      "iluau.chat_inbox",
      "iluau.chat_reply",
    ],
    bridgeJobTypes: [
      "ping",
      "inspect_selection",
      "get_properties",
      "get_attributes",
      "set_attributes",
      "get_tags",
      "set_tags",
      "set_property",
      "set_properties",
      "create_instance",
      "delete_instance",
      "sync_snapshot",
      "get_tree",
      "run_luau",
    ],
  };
}

module.exports = {
  state,
  queueJob,
  waitForJobResult,
  getNextPendingJob,
  markBridgeHeartbeat,
  markJobCompleted,
  getPublicState,
  getCapabilities,
  addChatMessage,
  getChatMessages,
  takePendingChatPrompts,
  nowIso,
};
