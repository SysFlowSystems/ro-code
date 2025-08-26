import 'dotenv/config';
import express from 'express';
import { listProjects, ensureProject, saveFilesToProject } from './projectManager.js';
import { startRojo, stopRojo, getRojoStatus, getRojoLogs } from './rojoManager.js';
import { exportProjectToRbxmx } from './rbxExport.js';

// Minimal RO-AI backend: serves static web/ and proxies OpenAI chat
const app = express();
app.use(express.json({ limit: '2mb' }));
app.use(express.static('web'));

app.get('/api/health', (_, res) => res.json({ ok: true }));

app.post('/api/openai/chat', async (req, res) => {
  try {
    const body = req.body || {};
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) return res.status(500).send('OPENAI_API_KEY missing on server');

    const r = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: body.model || 'gpt-4o-mini',
        messages: body.messages || [{ role: 'user', content: 'ping' }],
        temperature: body.temperature ?? 0.35
      }),
      signal: AbortSignal.timeout(120000)
    });

    const text = await r.text();
    res.status(r.status).type('application/json').send(text);
  } catch (e) {
    res.status(500).send(e.message || 'Server error');
  }
});

// Project management
app.get('/api/projects', async (_, res) => {
  const projects = await listProjects();
  res.json({ projects });
});

app.post('/api/projects', async (req, res) => {
  const { name, template } = req.body || {};
  if (!name) return res.status(400).json({ error: 'name required' });
  await ensureProject(name, template);
  res.json({ ok: true });
});

// Code save
app.post('/api/projects/:name/files', async (req, res) => {
  const { name } = req.params;
  const { files } = req.body || {};
  if (!Array.isArray(files)) return res.status(400).json({ error: 'files[] required' });
  const saved = await saveFilesToProject(name, files);
  res.json({ saved });
});

// Rojo control
app.post('/api/projects/:name/rojo/start', (req, res) => {
  const { name } = req.params;
  const status = startRojo(name);
  res.json(status);
});

app.post('/api/projects/:name/rojo/stop', (req, res) => {
  const { name } = req.params;
  stopRojo(name);
  res.json({ running: false });
});

app.get('/api/projects/:name/rojo/status', (req, res) => {
  const { name } = req.params;
  res.json(getRojoStatus(name));
});

app.get('/api/projects/:name/rojo/logs', (req, res) => {
  const { name } = req.params;
  res.json({ logs: getRojoLogs(name) });
});

// Export to .rbxmx
app.post('/api/projects/:name/export', async (req, res) => {
  const { name } = req.params;
  const result = await exportProjectToRbxmx(name);
  res.json(result);
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`RO-AI server running on http://localhost:${PORT}`));


