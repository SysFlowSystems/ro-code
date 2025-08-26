Ro‑AI + n8n — Roblox Project Generator

Overview
- This repo now hosts the Ro‑AI agent workflow (n8n) and helper docs for a website that requests a generated, Rojo‑ready Roblox project (returned as a ZIP).
- The previous Roblox lobby code was removed per request. You can regenerate fresh projects on demand via the webhook.

What’s included
- tools/n8n/roblox_game_agent_workflow.json — fully wired n8n workflow.
- tools/n8n/README.md — import, env, and usage notes.
- default.project.json — example Rojo mapping (kept for reference; not used by Ro‑AI site directly).

Quick start (n8n)
1) Open n8n → Workflows → Import from file → select tools/n8n/roblox_game_agent_workflow.json → Import → Activate.
2) n8n → Settings → Variables → add OPENAI_API_KEY with your key.
3) (Optional) Secure the Webhook node with a header (e.g., x-ro-ai-secret) and send it from your backend.
4) Copy the Production webhook URL from the Webhook node (ends with /roblox/generate).

Test the webhook
```bash
curl -X POST "<PROD_WEBHOOK_URL>" \
  -H "Content-Type: application/json" \
  -d '{"projectName":"Fractured Reality","brief":"Monochrome horror loading lobby"}' \
  --output project.zip
```
You should receive project.zip containing a complete Rojo‑ready project (files + README).

Hook up your website (recommended backend proxy)
- Add a small Express route (or any backend) to forward requests to the n8n Production URL so your API key stays in n8n and you avoid browser CORS:
```js
// .env: N8N_WEBHOOK_URL=...  ROAI_SECRET=optional
app.post("/api/generate", async (req, res) => {
  const r = await fetch(process.env.N8N_WEBHOOK_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-ro-ai-secret": process.env.ROAI_SECRET || ""
    },
    body: JSON.stringify(req.body),
    signal: AbortSignal.timeout(120000)
  });
  if (!r.ok) return res.status(r.status).send(await r.text());
  res.setHeader("Content-Type", "application/zip");
  res.setHeader("Content-Disposition", "attachment; filename=project.zip");
  r.body.pipe(res);
});
```

Client contract (simple)
- POST to /api/generate with JSON body:
  - projectName: string
  - brief: string (freeform requirements)
- Response: application/zip (binary). Save the blob as project.zip. Optionally parse with JSZip to preview files.

Notes
- Keep your OpenAI key in n8n, not the website.
- If you still use Rojo locally, ensure Workspace maps to a folder in default.project.json (e.g., ./src/Workspace).
- The repo’s previous Roblox code was intentionally cleared to fully switch to the Ro‑AI generation flow.

Fractured Reality — Immersive Lobby/Loading Screen

This project contains a self-contained Roblox lobby that doubles as a loading screen for Chapter 1. It builds an unsettling environment server-side and assembles UI, audio, and preload logic client-side.

Structure
- `default.project.json`: Rojo project mapping.
- `src/ReplicatedStorage/Fractured`:
  - `Config.lua`: chapters, UI colors, image/audio ids, lore, preload lists.
  - `Net.lua`: remote event helper.
  - `Preloader.lua`: asset preloading with progress callbacks.
  - `UIBuilder.lua`: ScreenGui, progress bar, lore, chapter list (locks, hover).
  - `AudioController.lua`: ambient loops, locked hints, transition rumble.
- `src/ServerStorage/Fractured/EnvironmentBuilder.lua`: builds the ground-level lobby: floor, walls, ceiling beams, lights (flicker), vents, pipes, debris, fog, dust, moving shadows.
- `src/ServerScriptService/LobbyServer.server.lua`: builds environment and handles StartChapter event.
- `src/StarterPlayer/StarterPlayerScripts/LobbyClient.client.lua`: constructs UI, runs preload, animates flicker/shadows, plays audio, handles chapter clicks and fade.

Running
1) Install Rojo: rbxstudio plugin + rojo CLI.
2) In Studio, create a new experience (place) and open the Rojo plugin.
3) From terminal, in this directory, run:
   rojo serve | cat
4) In Studio, connect to the Rojo session. The files will sync into Services:
   - `ReplicatedStorage/Fractured/...`
   - `ServerStorage/Fractured/EnvironmentBuilder`
   - `ServerScriptService/LobbyServer`
   - `StarterPlayer/StarterPlayerScripts/LobbyClient`
5) Press Play. You should see:
   - A grimy facility lobby with fog, dust, pipes, debris, flickering lights.
   - A lobby UI with progress bar, lore tips, and chapter list.
   - Only Chapter 1 clickable; others locked with subtle movement/sounds.
   - Clicking Chapter 1 triggers rumble, fade to black, then places you near `Chapter1Spawn`.

Notes
- Replace placeholder asset IDs in `Config.lua` (`Images` and `Audio`) with your uploaded assets to pass moderation and preload correctly.
- To teleport to a separate Chapter 1 place, set `Config.Chapters[1].placeId` to your place ID.
- Lighting uses `Technology = Future` (with pcall) and post-processing for unease.
- Performance: particles are lightweight and lights flicker with small, randomized intervals.


