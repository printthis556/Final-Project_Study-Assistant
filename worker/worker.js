// worker.js (paste this into Cloudflare Worker editor)

export default {
  async fetch(request, env, ctx) {
    return handleRequest(request);
  }
};

async function handleRequest(request) {
  // Handle CORS preflight
  if (request.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
    });
  }

  // Only allow POST
  if (request.method !== 'POST') {
    return new Response(
      JSON.stringify({ error: 'Only POST supported' }),
      {
        status: 405,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        }
      }
    );
  }

  // Parse JSON body
  let payload;
  try {
    payload = await request.json();
  } catch (e) {
    return new Response(
      JSON.stringify({ error: 'Invalid JSON' }),
      {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        }
      }
    );
  }

  const notes = (payload && payload.notes) ? String(payload.notes) : '';

  // Simple deterministic flashcard generation.
  const blocks = notes
    .split(/\r?\n\s*\r?\n/)
    .map(b => b.trim())
    .filter(b => b.length > 0);

  const cards = blocks.map((block) => {
    const firstLine = block.split(/\r?\n/)[0].trim();
    const q = firstLine.length > 0
      ? `Explain: ${firstLine}`
      : 'Explain this topic';
    return { question: q, answer: block };
  });

  return new Response(JSON.stringify(cards), {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    }
  });
}
