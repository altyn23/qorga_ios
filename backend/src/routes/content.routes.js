const express = require('express');
const router = express.Router();
const axios = require('axios');
const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');
const User = require('../models/user');
const PsychLot = require('../models/PsychLot');

const uploadsRoot = path.resolve(__dirname, '../../uploads');
const uploadsVideoDir = path.join(uploadsRoot, 'videos');
fs.mkdirSync(uploadsVideoDir, { recursive: true });

function isValidObjectId(id) {
  return mongoose.Types.ObjectId.isValid(id);
}

function publicBaseUrl(req) {
  const configured = (process.env.PUBLIC_BASE_URL || '').trim();
  if (configured) return configured.replace(/\/+$/, '');
  return `${req.protocol}://${req.get('host')}`;
}

function extensionFromMime(mimeType) {
  const map = {
    'video/mp4': '.mp4',
    'video/quicktime': '.mov',
    'video/x-msvideo': '.avi',
    'video/x-matroska': '.mkv',
    'video/webm': '.webm',
  };
  return map[mimeType] || '.mp4';
}

async function getJson(url) {
  const r = await axios.get(url, { timeout: 12000 });
  return r.data;
}

function getFallbackArticles() {
  return [
    {
      title: 'Teen mental health',
      description:
          'WHO materials and updates on adolescent mental health and support.',
      url: 'https://www.who.int/news-room/fact-sheets/detail/adolescent-mental-health',
      imageUrl: '',
      source: 'WHO',
      publishedAt: null,
    },
    {
      title: 'Bullying prevention resources',
      description:
          'UNICEF guidance and practical materials for parents and schools.',
      url: 'https://www.unicef.org/protection/bullying',
      imageUrl: '',
      source: 'UNICEF',
      publishedAt: null,
    },
    {
      title: 'Youth and anxiety support tips',
      description:
          'Practical recommendations and evidence-based support approaches.',
      url: 'https://www.mind.org.uk/information-support/for-children-and-young-people/',
      imageUrl: '',
      source: 'Mind',
      publishedAt: null,
    },
    {
      title: 'Helping children with stress',
      description:
          'Psychological support suggestions for families and educators.',
      url: 'https://www.apa.org/topics/children/stress',
      imageUrl: '',
      source: 'APA',
      publishedAt: null,
    },
  ];
}

router.get('/articles', async (req, res) => {
  try {
    const userQ = (req.query.q || '').trim();
    const lang = (req.query.lang || 'kk').trim();
    const max = Math.min(parseInt(req.query.max || '10', 10), 20);

    if (!process.env.NEWS_API_KEY) {
      return res.json({
        ok: true,
        langTried: lang,
        total: getFallbackArticles().length,
        items: getFallbackArticles(),
        fallback: true,
      });
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
    const fallback = getFallbackArticles();
    return res.json({
      ok: true,
      total: fallback.length,
      items: fallback,
      fallback: true,
      error: e.message || 'Failed to fetch articles',
    });
  }
});

// GET /content/lots
router.get('/lots', async (_req, res) => {
  try {
    const lots = await PsychLot.find({}, null, { sort: { createdAt: -1 } }).lean();
    return res.json({
      ok: true,
      items: lots.map((lot) => ({
        id: lot._id,
        psychologistId: lot.psychologistId,
        psychologistName: lot.psychologistName,
        title: lot.title,
        description: lot.description,
        videoUrl: lot.videoUrl,
        videoOriginalName: lot.videoOriginalName,
        createdAt: lot.createdAt,
      })),
    });
  } catch (err) {
    console.error('lots list error:', err);
    return res.status(500).json({ ok: false, error: 'Failed to load psychologist lots' });
  }
});

// POST /content/lots
// JSON fields: psychologistId, title, description, videoBase64, videoName, mimeType
router.post('/lots', async (req, res) => {
  try {
    const { psychologistId, title, description, videoBase64, videoName, mimeType } = req.body || {};

    if (!isValidObjectId(psychologistId)) {
      return res.status(400).json({ ok: false, error: 'Valid psychologistId is required' });
    }
    if (!title || !title.trim()) {
      return res.status(400).json({ ok: false, error: 'Title is required' });
    }
    if (!videoBase64 || typeof videoBase64 !== 'string') {
      return res.status(400).json({ ok: false, error: 'Video file is required' });
    }

    const rawBase64 = videoBase64.includes(',') ? videoBase64.split(',').pop() : videoBase64;
    const buffer = Buffer.from(rawBase64 || '', 'base64');
    if (!buffer.length) {
      return res.status(400).json({ ok: false, error: 'Video payload is empty' });
    }
    if (buffer.length > 200 * 1024 * 1024) {
      return res.status(400).json({ ok: false, error: 'Video is too large (max 200MB)' });
    }

    const psychologist = await User.findById(psychologistId, { role: 1, displayName: 1, email: 1 }).lean();
    if (!psychologist) {
      return res.status(404).json({ ok: false, error: 'Psychologist not found' });
    }
    if (psychologist.role !== 'psychologist') {
      return res.status(403).json({ ok: false, error: 'Only psychologist can publish lots' });
    }

    const safeExt = path.extname(videoName || '').toLowerCase() || extensionFromMime(mimeType);
    const filename = `${Date.now()}-${Math.round(Math.random() * 1e9)}${safeExt}`;
    fs.writeFileSync(path.join(uploadsVideoDir, filename), buffer);

    const relativeVideoPath = `/uploads/videos/${filename}`;
    const videoUrl = `${publicBaseUrl(req)}${relativeVideoPath}`;

    const lot = await PsychLot.create({
      psychologistId,
      psychologistName: psychologist.displayName || psychologist.email || 'Psychologist',
      title: title.trim(),
      description: (description || '').trim(),
      videoUrl,
      videoOriginalName: (videoName || '').trim(),
    });

    return res.status(201).json({
      ok: true,
      item: {
        id: lot._id,
        psychologistId: lot.psychologistId,
        psychologistName: lot.psychologistName,
        title: lot.title,
        description: lot.description,
        videoUrl: lot.videoUrl,
        videoOriginalName: lot.videoOriginalName,
        createdAt: lot.createdAt,
      },
    });
  } catch (err) {
    console.error('lots create error:', err);
    return res.status(500).json({ ok: false, error: err.message || 'Failed to create lot' });
  }
});

module.exports = router;
