const fetch = (...a) => import('node-fetch').then(({default: f}) => f(...a));

exports.handler = async (event) => {
  try {
    if (event.httpMethod !== 'POST') {
      return { statusCode: 405, body: 'Method Not Allowed' };
    }

    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) return { statusCode: 500, body: 'OPENAI_API_KEY missing' };

    const body = JSON.parse(event.body || '{}');
    const payload = {
      model: body.model || 'gpt-4o-mini',
      messages: body.messages || [{ role: 'user', content: 'ping' }],
      temperature: body.temperature ?? 0.35
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
