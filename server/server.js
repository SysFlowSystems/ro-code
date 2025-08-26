import 'dotenv/config';
import express from 'express';

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

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`RO-AI server running on http://localhost:${PORT}`));


