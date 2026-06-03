#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");
const http = require("node:http");
const readline = require("node:readline");
const {
  state,
  queueJob,
  waitForJobResult,
  getNextPendingJob,
  markBridgeHeartbeat,
  markJobCompleted,
  getPublicState,
  getCapabilities,
  nowIso,
} = require("./store");

const ROOT = path.resolve(__dirname, "..");
const dashboardDir = path.join(ROOT, "dashboard");
const studioPluginDir = path.join(ROOT, "studio-plugin");

function write(obj) {
  process.stdout.write(`${JSON.stringify(obj)}\n`);
}

function textContent(text) {
  return [{ type: "text", text }];
}

function jsonText(value) {
  return JSON.stringify(value, null, 2);
}

function ok(id, result) {
  write({ jsonrpc: "2.0", id, result });
}

function fail(id, code, message, data) {
  const error = { code, message };
  if (data !== undefined) error.data = data;
  write({ jsonrpc: "2.0", id, error });
}

function readStatic(filePath, contentType) {
  const body = fs.readFileSync(filePath);
  return { body, contentType };
}

function renderDashboard() {
  const index = path.join(dashboardDir, "index.html");
  return readStatic(index, "text/html; charset=utf-8");
}

function contentTypeFor(filePath) {
  if (filePath.endsWith(".css")) return "text/css; charset=utf-8";
  if (filePath.endsWith(".js")) return "application/javascript; charset=utf-8";
  if (filePath.endsWith(".svg")) return "image/svg+xml";
  if (filePath.endsWith(".png")) return "image/png";
  return "text/plain; charset=utf-8";
}

function serveDashboard(req, res) {
  const url = new URL(req.url, "http://127.0.0.1");

  if (req.method === "GET" && url.pathname === "/") {
    const page = renderDashboard();
    res.writeHead(200, { "Content-Type": page.contentType });
    res.end(page.body);
    return;
  }

  if (req.method === "GET" && url.pathname.startsWith("/assets/")) {
    const filePath = path.join(dashboardDir, url.pathname.replace("/assets/", ""));
    if (!filePath.startsWith(dashboardDir)) {
      res.writeHead(403);
      res.end("Forbidden");
      return;
    }
    if (!fs.existsSync(filePath)) {
      res.writeHead(404);
      res.end("Not found");
      return;
    }
    const body = fs.readFileSync(filePath);
    res.writeHead(200, { "Content-Type": contentTypeFor(filePath) });
    res.end(body);
    return;
  }

  if (req.method === "GET" && url.pathname === "/api/state") {
    res.writeHead(200, { "Content-Type": "application/json; charset=utf-8" });
    res.end(JSON.stringify(getPublicState()));
    return;
  }

  if (req.method === "GET" && url.pathname === "/api/jobs") {
    res.writeHead(200, { "Content-Type": "application/json; charset=utf-8" });
    res.end(JSON.stringify({ jobs: state.jobs }));
    return;
  }

  if (req.method === "GET" && url.pathname === "/api/bridge/next") {
    const clientId = url.searchParams.get("clientId");
    const job = getNextPendingJob(clientId);
    res.writeHead(200, { "Content-Type": "application/json; charset=utf-8" });
    res.end(JSON.stringify({ job }));
    return;
  }

  if (req.method === "POST" && url.pathname === "/api/bridge/heartbeat") {
    readJson(req).then((payload) => {
      const clientId = markBridgeHeartbeat(payload || {});
      res.writeHead(200, { "Content-Type": "application/json; charset=utf-8" });
      res.end(JSON.stringify({ ok: true, clientId, bridge: state.bridge }));
    }).catch((error) => respondError(res, 400, error.message));
    return;
  }

  if (req.method === "POST" && url.pathname === "/api/bridge/result") {
    readJson(req).then((payload) => {
      const updated = markJobCompleted(payload.jobId, payload.result, payload.error);
      res.writeHead(updated ? 200 : 404, { "Content-Type": "application/json; charset=utf-8" });
      res.end(JSON.stringify({ ok: !!updated, job: updated }));
    }).catch((error) => respondError(res, 400, error.message));
    return;
  }

  if (req.method === "POST" && url.pathname === "/api/jobs") {
    readJson(req).then((payload) => {
      if (!payload || typeof payload.type !== "string") {
        respondError(res, 400, "Missing job type");
        return;
      }
      const job = queueJob(payload.type, payload.payload || {});
      res.writeHead(201, { "Content-Type": "application/json; charset=utf-8" });
      res.end(JSON.stringify({ ok: true, job }));
    }).catch((error) => respondError(res, 400, error.message));
    return;
  }

  res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
  res.end("Not found");
}

function respondError(res, status, message) {
  res.writeHead(status, { "Content-Type": "application/json; charset=utf-8" });
  res.end(JSON.stringify({ ok: false, error: message }));
}

function readJson(req) {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
      if (body.length > 1_000_000) {
        reject(new Error("Request body too large"));
        req.destroy();
      }
    });
    req.on("end", () => {
      if (!body) return resolve({});
      try {
        resolve(JSON.parse(body));
      } catch (error) {
        reject(error);
      }
    });
    req.on("error", reject);
  });
}

function bridgeJobSummary(job) {
  return {
    id: job.id,
    type: job.type,
    status: job.status,
    createdAt: job.createdAt,
    updatedAt: job.updatedAt,
    result: job.result,
    error: job.error,
  };
}

async function dispatchBridgeJob(type, payload, timeoutMs = 30000) {
  const job = queueJob(type, payload);
  if (!state.bridge.connected) {
    return {
      ok: false,
      queued: true,
      job: bridgeJobSummary(job),
      error: "Bridge not connected",
    };
  }
  try {
    const completed = await waitForJobResult(job.id, timeoutMs);
    return {
      ok: true,
      job: bridgeJobSummary(completed),
    };
  } catch (error) {
    return {
      ok: false,
      queued: true,
      job: bridgeJobSummary(job),
      error: error?.message || String(error),
    };
  }
}

const httpServer = http.createServer(serveDashboard);
httpServer.listen(state.dashboardPort, "127.0.0.1", () => {
  state.runtime.dashboardStartedAt = nowIso();
});

const tools = [
  {
    name: "iluau.ping",
    description: "Check that the local iLuau MCP server is alive.",
    inputSchema: {
      type: "object",
      properties: {
        message: { type: "string", description: "Optional message to echo back." },
      },
      additionalProperties: false,
    },
  },
  {
    name: "iluau.status",
    description: "Return the current iLuau server and bridge status.",
    inputSchema: {
      type: "object",
      properties: {},
      additionalProperties: false,
    },
  },
  {
    name: "iluau.capabilities",
    description: "List the features that this local plugin currently exposes.",
    inputSchema: {
      type: "object",
      properties: {},
      additionalProperties: false,
    },
  },
  {
    name: "iluau.inspect_selection",
    description: "Inspect the current Studio selection and return its details.",
    inputSchema: {
      type: "object",
      properties: {
        timeoutMs: { type: "number" },
      },
      additionalProperties: false,
    },
  },
  {
    name: "iluau.get_properties",
    description: "Read one or more properties from a Roblox instance by path.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
        properties: {
          type: "array",
          items: { type: "string" },
        },
        timeoutMs: { type: "number" },
      },
      required: ["path", "properties"],
      additionalProperties: false,
    },
  },
  {
    name: "iluau.get_attributes",
    description: "Read the attributes from a Roblox instance by path.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
        timeoutMs: { type: "number" },
      },
      required: ["path"],
      additionalProperties: false,
    },
  },
  {
    name: "iluau.set_attributes",
    description: "Set multiple attributes on a Roblox instance by path.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
        attributes: { type: "object" },
        timeoutMs: { type: "number" },
      },
      required: ["path", "attributes"],
      additionalProperties: false,
    },
  },
  {
    name: "iluau.get_tags",
    description: "Read CollectionService tags from a Roblox instance by path.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
        timeoutMs: { type: "number" },
      },
      required: ["path"],
      additionalProperties: false,
    },
  },
  {
    name: "iluau.set_tags",
    description: "Replace CollectionService tags on a Roblox instance by path.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
        tags: {
          type: "array",
          items: { type: "string" },
        },
        timeoutMs: { type: "number" },
      },
      required: ["path", "tags"],
      additionalProperties: false,
    },
  },
  {
    name: "iluau.set_property",
    description: "Set a single property on a Roblox instance by path.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
        property: { type: "string" },
        value: {},
        timeoutMs: { type: "number" },
      },
      required: ["path", "property", "value"],
      additionalProperties: false,
    },
  },
  {
    name: "iluau.set_properties",
    description: "Set multiple properties, attributes, and tags on a Roblox instance by path.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
        properties: {
          type: "object",
        },
        attributes: { type: "object" },
        tags: {
          type: "array",
          items: { type: "string" },
        },
        timeoutMs: { type: "number" },
      },
      required: ["path", "properties"],
      additionalProperties: false,
    },
  },
  {
    name: "iluau.create_instance",
    description: "Create a Roblox instance under a parent path.",
    inputSchema: {
      type: "object",
      properties: {
        className: { type: "string" },
        parentPath: { type: "string" },
        name: { type: "string" },
        properties: { type: "object" },
        attributes: { type: "object" },
        tags: {
          type: "array",
          items: { type: "string" },
        },
        children: {
          type: "array",
          items: {
            type: "object",
            properties: {
              className: { type: "string" },
              name: { type: "string" },
              properties: { type: "object" },
              attributes: { type: "object" },
              tags: {
                type: "array",
                items: { type: "string" },
              },
              children: {
                type: "array",
                items: {
                  type: "object",
                  additionalProperties: true,
                },
              },
            },
            additionalProperties: true,
          },
        },
        timeoutMs: { type: "number" },
      },
      required: ["className"],
      additionalProperties: false,
    },
  },
  {
    name: "iluau.delete_instance",
    description: "Delete a Roblox instance by path.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string" },
        timeoutMs: { type: "number" },
      },
      required: ["path"],
      additionalProperties: false,
    },
  },
  {
    name: "iluau.sync_snapshot",
    description: "Capture a current snapshot of Studio selection and place metadata.",
    inputSchema: {
      type: "object",
      properties: {
        timeoutMs: { type: "number" },
      },
      additionalProperties: false,
    },
  },
  {
    name: "iluau.dashboard_url",
    description: "Return the local dashboard URL.",
    inputSchema: {
      type: "object",
      properties: {},
      additionalProperties: false,
    },
  },
  {
    name: "iluau.queue_job",
    description: "Queue a Roblox Studio bridge job for the Studio plugin to process.",
    inputSchema: {
      type: "object",
      properties: {
        type: { type: "string" },
        payload: { type: "object" },
      },
      required: ["type"],
      additionalProperties: false,
    },
  },
  {
    name: "iluau.list_jobs",
    description: "List recent bridge jobs and their status.",
    inputSchema: {
      type: "object",
      properties: {
        status: { type: "string" },
        limit: { type: "number" },
      },
      additionalProperties: false,
    },
  },
  {
    name: "iluau.bridge_state",
    description: "Return the current bridge connection state.",
    inputSchema: {
      type: "object",
      properties: {},
      additionalProperties: false,
    },
  },
];

function handlePing(params) {
  const timestamp = nowIso();
  state.runtime.lastPingAt = timestamp;
  return textContent(
    jsonText({
      ok: true,
      pluginName: state.pluginName,
      version: state.version,
      timestamp,
      echo: params?.message ?? null,
    })
  );
}

function handleStatus() {
  return textContent(jsonText(getPublicState()));
}

function handleCapabilities() {
  return textContent(jsonText(getCapabilities()));
}

function handleDashboardUrl() {
  return textContent(`http://127.0.0.1:${state.dashboardPort}/`);
}

async function handleQueueJob(params) {
  const job = queueJob(params.type, params.payload || {});
  return textContent(jsonText({ ok: true, job: bridgeJobSummary(job) }));
}

function handleListJobs(params) {
  const limit = Number.isFinite(params?.limit) ? params.limit : 20;
  const jobs = state.jobs.filter((job) => !params?.status || job.status === params.status).slice(0, limit);
  return textContent(jsonText({ jobs }));
}

function handleBridgeState() {
  return textContent(jsonText(state.bridge));
}

async function handleInspectSelection(params) {
  return textContent(jsonText(await dispatchBridgeJob("inspect_selection", {}, params?.timeoutMs || 30000)));
}

async function handleGetProperties(params) {
  return textContent(jsonText(await dispatchBridgeJob("get_properties", {
    path: params.path,
    properties: params.properties,
  }, params?.timeoutMs || 30000)));
}

async function handleGetAttributes(params) {
  return textContent(jsonText(await dispatchBridgeJob("get_attributes", {
    path: params.path,
  }, params?.timeoutMs || 30000)));
}

async function handleSetAttributes(params) {
  return textContent(jsonText(await dispatchBridgeJob("set_attributes", {
    path: params.path,
    attributes: params.attributes,
  }, params?.timeoutMs || 30000)));
}

async function handleGetTags(params) {
  return textContent(jsonText(await dispatchBridgeJob("get_tags", {
    path: params.path,
  }, params?.timeoutMs || 30000)));
}

async function handleSetTags(params) {
  return textContent(jsonText(await dispatchBridgeJob("set_tags", {
    path: params.path,
    tags: params.tags,
  }, params?.timeoutMs || 30000)));
}

async function handleSetProperty(params) {
  return textContent(jsonText(await dispatchBridgeJob("set_property", {
    path: params.path,
    property: params.property,
    value: params.value,
  }, params?.timeoutMs || 30000)));
}

async function handleSetProperties(params) {
  return textContent(jsonText(await dispatchBridgeJob("set_properties", {
    path: params.path,
    properties: params.properties,
    attributes: params.attributes || {},
    tags: params.tags || [],
  }, params?.timeoutMs || 30000)));
}

async function handleCreateInstance(params) {
  return textContent(jsonText(await dispatchBridgeJob("create_instance", {
    className: params.className,
    parentPath: params.parentPath || "game.Workspace",
    name: params.name,
    properties: params.properties || {},
    attributes: params.attributes || {},
    tags: params.tags || [],
    children: params.children || [],
  }, params?.timeoutMs || 30000)));
}

async function handleDeleteInstance(params) {
  return textContent(jsonText(await dispatchBridgeJob("delete_instance", {
    path: params.path,
  }, params?.timeoutMs || 30000)));
}

async function handleSyncSnapshot(params) {
  return textContent(jsonText(await dispatchBridgeJob("sync_snapshot", {}, params?.timeoutMs || 30000)));
}

const handlers = {
  "iluau.ping": handlePing,
  "iluau.status": handleStatus,
  "iluau.capabilities": handleCapabilities,
  "iluau.inspect_selection": handleInspectSelection,
  "iluau.get_properties": handleGetProperties,
  "iluau.get_attributes": handleGetAttributes,
  "iluau.set_attributes": handleSetAttributes,
  "iluau.get_tags": handleGetTags,
  "iluau.set_tags": handleSetTags,
  "iluau.set_property": handleSetProperty,
  "iluau.set_properties": handleSetProperties,
  "iluau.create_instance": handleCreateInstance,
  "iluau.delete_instance": handleDeleteInstance,
  "iluau.sync_snapshot": handleSyncSnapshot,
  "iluau.dashboard_url": handleDashboardUrl,
  "iluau.queue_job": handleQueueJob,
  "iluau.list_jobs": handleListJobs,
  "iluau.bridge_state": handleBridgeState,
};

const rl = readline.createInterface({
  input: process.stdin,
  crlfDelay: Infinity,
});

rl.on("line", (line) => {
  if (!line.trim()) return;

  let msg;
  try {
    msg = JSON.parse(line);
  } catch {
    return;
  }

  const id = msg.id;
  const method = msg.method;

  if (method === "initialize") {
    return ok(id, {
      protocolVersion: "2024-11-05",
      serverInfo: {
        name: "iluau-roblox-mcp",
        version: state.version,
      },
      capabilities: {
        tools: {},
      },
    });
  }

  if (method === "notifications/initialized") {
    return;
  }

  if (method === "tools/list") {
    return ok(id, { tools });
  }

  if (method === "tools/call") {
    const toolName = msg.params?.name;
    const args = msg.params?.arguments ?? {};
    const handler = handlers[toolName];
    if (!handler) return fail(id, -32601, `Unknown tool: ${toolName}`);
    try {
      Promise.resolve(handler(args))
        .then((content) => ok(id, { content }))
        .catch((error) => fail(id, -32000, error?.message || "Tool execution failed", { stack: error?.stack }));
      return;
    } catch (error) {
      return fail(id, -32000, error?.message || "Tool execution failed", { stack: error?.stack });
    }
  }

  if (id !== undefined) {
    return fail(id, -32601, `Unknown method: ${method}`);
  }
});

process.on("SIGINT", () => process.exit(0));
process.on("SIGTERM", () => process.exit(0));
