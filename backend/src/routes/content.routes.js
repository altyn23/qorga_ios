const express = require('express');
const router = express.Router();
const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));

async function getJson(url) {
  const r = await fetch(url);
  const text = await r.text();
  let json;
  try { json = JSON.parse(text); } catch (_) { json = { raw: text }; }
  if (!r.ok) {
    const msg = json?.message || json?.error || `HTTP ${r.status}`;
    throw new Error(`Upstream error: ${msg}`);
  }
  return json;
}

router.get('/articles', async (req, res) => {
  try {
    const userQ = (req.query.q || '').trim();
    const lang = (req.query.lang || 'kk').trim();
    const max = Math.min(parseInt(req.query.max || '10', 10), 20);

    if (!process.env.NEWS_API_KEY) {
      return res.status(500).json({ ok: false, error: 'NEWS_API_KEY missing' });
    }

    // Поисковый запрос
    const query = userQ || 'буллинг OR кибербуллинг OR мектептегі зорлық';

    // URL для News API
    const base = new URL('https://newsapi.org/v2/everything');
    base.searchParams.set('q', query);
    base.searchParams.set('language', lang);
    base.searchParams.set('pageSize', String(max));
    base.searchParams.set('sortBy', 'publishedAt');
    base.searchParams.set('apiKey', process.env.NEWS_API_KEY);

    const raw = await getJson(base.toString());
    if (!raw.articles || !Array.isArray(raw.articles)) {
      throw new Error('Unexpected response from NewsAPI');
    }

    // Преобразуем в удобный формат для Flutter
    const items = raw.articles.map((a) => ({
      title: a.title,
      description: a.description,
      url: a.url,
      imageUrl: a.urlToImage,
      source: a.source?.name,
      publishedAt: a.publishedAt,
    }));

    return res.json({ ok: true, langTried: lang, total: items.length, items });
  } catch (e) {
    console.error('articles error:', e);
    return res.status(502).json({ ok: false, error: e.message || 'Failed to fetch articles' });
  }
});

module.exports = router;
