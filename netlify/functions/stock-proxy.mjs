// Yahoo Finance's chart endpoint answers fine server-to-server but never sends
// CORS headers, so a browser can't read the response directly (confirmed: 200 OK,
// blocked by Access-Control-Allow-Origin). This function runs on Netlify's servers,
// fetches Yahoo on the page's behalf, and hands the JSON back with CORS allowed.

export default async (request) => {
  const url = new URL(request.url);
  const symbol = url.searchParams.get("symbol");

  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json",
  };

  if (!symbol || !/^[A-Za-z0-9.\-]{1,10}$/.test(symbol)) {
    return new Response(JSON.stringify({ error: "Invalid or missing symbol" }), {
      status: 400,
      headers: corsHeaders,
    });
  }

  try {
    const yahooUrl = `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(symbol)}?interval=1d&range=3mo`;
    const res = await fetch(yahooUrl, { headers: { "User-Agent": "Mozilla/5.0" } });
    if (!res.ok) {
      return new Response(JSON.stringify({ error: `Yahoo responded ${res.status}` }), {
        status: 502,
        headers: corsHeaders,
      });
    }
    const data = await res.json();
    return new Response(JSON.stringify(data), { status: 200, headers: corsHeaders });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: corsHeaders,
    });
  }
};
