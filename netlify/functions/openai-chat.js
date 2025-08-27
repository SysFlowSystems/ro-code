const fetch = (...a) => import('node-fetch').then(({default: f}) => f(...a));

exports.handler = async (event) => {
  try {
    if (event.httpMethod !== 'POST') {
      return { statusCode: 405, body: 'Method Not Allowed' };
    }

    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) return { statusCode: 500, body: 'OPENAI_API_KEY missing' };

    const body = JSON.parse(event.body || '{}');

    // Prefer your fine-tuned model from env unless client overrides
    const defaultModel = process.env.OPENAI_MODEL || 'gpt-4o-mini';

    // Build messages; inject a strong system prompt if none provided
    const systemPrompt = 'You are a senior Roblox/Lua generator. Produce complete, modular files with a Rojo layout. Server-authoritative. Unless asked, reply with only the requested code or data.';
    let messages = Array.isArray(body.messages) ? body.messages.slice() : [];
    if (messages.length === 0) {
      const prompt = typeof body.prompt === 'string' ? body.prompt : 'Generate a minimal Roblox project scaffold with one AI entity.';
      messages = [{ role: 'user', content: prompt }];
    }
    if (!messages.find((m) => m && m.role === 'system')) {
      messages.unshift({ role: 'system', content: systemPrompt });
    }

    const payload = {
      model: body.model || defaultModel,
      messages,
      temperature: body.temperature ?? 0.5
    };

    const r = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    const text = await r.text();
    return {
      statusCode: r.status,
      headers: { 'Content-Type': 'application/json' },
      body: text
    };
  } catch (err) {
    return { statusCode: 500, body: err.message || 'Server error' };
  }
};
