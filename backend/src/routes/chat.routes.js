const express = require('express');
const router = express.Router();
const axios = require('axios');

router.post('/send', async (req, res) => {
  try {
    const { message } = req.body;

    if (!message || !message.trim()) {
      return res
        .status(400)
        .json({ reply: 'Алдымен сұрағыңызды жазыңыз.' });
    }

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      console.error('GEMINI_API_KEY is not set');
      return res.status(500).json({
        reply: 'Сервер баптауларында қате бар (GEMINI_API_KEY).',
      });
    }

    // ✅ Переходим на v1 и ставим нормальную модель по умолчанию
// ✅ Переходим на v1 и ставим нормальную модель по умолчанию
    const model = process.env.GEMINI_MODEL || 'gemini-2.5-flash'; // Обновляем резервное имя модели
    const url = `https://generativelanguage.googleapis.com/v1/models/${model}:generateContent`;

    const response = await axios.post(
      `${url}?key=${apiKey}`,
      {
        contents: [
          {
            role: 'user',
            parts: [
              {
                text:
                  'Сен студенттерге арналған психологиялық көмекші чат-ботсың. ' +
                  'Жылы, түсіністікпен, қысқа және қарапайым қазақ тілінде жауап бер. ' +
                  'Қауіпті кеңестер берме, өзіне қол жұмсау туралы нұсқаулық жазба. ' +
                  'Міне, пайдаланушының хабары: ' +
                  message,
              },
            ],
          },
        ],
      },
      {
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    let reply = 'Кешіріңіз, жауап бере алмадым.';
    const candidates = response.data.candidates || [];
    if (
      candidates.length > 0 &&
      candidates[0].content &&
      Array.isArray(candidates[0].content.parts)
    ) {
      reply = candidates[0].content.parts
        .map((p) => p.text || '')
        .join(' ')
        .trim();
    }

    return res.json({ reply });
  } catch (err) {
    console.error('Gemini error:', err.response?.data || err.message);
    return res.status(500).json({
      reply:
        'Серверде қате орын алды. Кейінірек қайталап көріңіз немесе басқа сұрақ қойып көріңіз.',
    });
  }
});

module.exports = router;
