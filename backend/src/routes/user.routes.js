const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
const User = require('../models/user'); // путь к модели
const UserAlert = require('../models/UserAlert');
const { validatePassword } = require('../utils/password-policy');

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const MAX_AVATAR_BASE64_BYTES = 1.5 * 1024 * 1024;

function isValidObjectId(id) {
  return mongoose.Types.ObjectId.isValid(id);
}

function validateAvatarBase64(value) {
  if (!value) return null;
  if (
    !/^data:image\/(png|jpeg|jpg|webp);base64,/i.test(value)
  ) {
    return 'avatarBase64 форматы қате';
  }

  const base64Data = value.split(',')[1] || '';
  const sizeBytes = Buffer.byteLength(base64Data, 'base64');
  if (sizeBytes > MAX_AVATAR_BASE64_BYTES) {
    return 'Аватар өлшемі 1.5MB-тан аспауы керек';
  }
  return null;
}

// GET /user/:id — получить профиль
router.get('/:id', async (req, res) => {
  try {
    const userId = String(req.params.id || '').trim();
    if (!isValidObjectId(userId)) {
      return res.status(400).json({ ok: false, message: 'Жарамды userId керек' });
    }

    const user = await User.findById(userId).lean();
    if (!user) {
      return res.status(404).json({ ok: false, message: 'Пайдаланушы табылмады' });
    }

    return res.json({
      ok: true,
      user: {
        id: user._id,
        name: user.displayName || '',
        email: user.email || '',
        role: user.role || 'user',
        avatarBase64: user.avatarBase64 || '',
      },
    });
  } catch (error) {
    console.error('User get error:', error);
    return res.status(500).json({ ok: false, message: 'Сервер қатесі' });
  }
});

// PUT /user/:id — обновить данные профиля
router.put('/:id', async (req, res) => {
  try {
    const { name, email, oldPassword, password, avatarBase64 } = req.body || {};
    const userId = String(req.params.id || '').trim();
    if (!isValidObjectId(userId)) {
      return res.status(400).json({ message: 'Жарамды userId керек' });
    }

    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ message: 'Пайдаланушы табылмады' });
    }

    // обновление имени и email
    if (name) user.displayName = name;
    if (email) {
      const normalizedEmail = String(email).trim().toLowerCase();
      if (!EMAIL_REGEX.test(normalizedEmail)) {
        return res.status(400).json({ message: 'Некорректный email' });
      }

      const conflict = await User.findOne({
        _id: { $ne: user._id },
        email: normalizedEmail,
      }).lean();
      if (conflict) {
        return res.status(409).json({ message: 'Email уже зарегистрирован' });
      }

      user.email = normalizedEmail;
    }

    if (avatarBase64 !== undefined) {
      const avatarValue = String(avatarBase64 || '').trim();
      const avatarError = validateAvatarBase64(avatarValue);
      if (avatarError) {
        return res.status(400).json({ message: avatarError });
      }
      user.avatarBase64 = avatarValue;
    }

    // если пришёл новый пароль — проверяем старый
    if (password) {
      const passwordError = validatePassword(password);
      if (passwordError) {
        return res.status(400).json({ message: passwordError });
      }

      if (!oldPassword) {
        return res
          .status(400)
          .json({ message: 'Ескі құпия сөз көрсетілмеген' });
      }

      const isMatch = await bcrypt.compare(oldPassword, user.passwordHash);
      if (!isMatch) {
        return res
          .status(400)
          .json({ message: 'Ескі құпия сөз қате' });
      }

      const salt = await bcrypt.genSalt(10);
      user.passwordHash = await bcrypt.hash(password, salt);
    }

    await user.save();

    res.status(200).json({
      message: 'Профиль сәтті жаңартылды',
      user: {
        id: user._id,
        name: user.displayName,
        email: user.email,
        role: user.role,
        avatarBase64: user.avatarBase64 || '',
      },
    });
  } catch (error) {
    console.error('User update error:', error);
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});

// GET /user/:id/alerts?unread=true
router.get('/:id/alerts', async (req, res) => {
  try {
    const userId = String(req.params.id || '').trim();
    if (!isValidObjectId(userId)) {
      return res.status(400).json({ ok: false, error: 'Жарамды userId керек' });
    }

    const unread = String(req.query.unread || '').trim().toLowerCase() === 'true';
    const query = { userId };
    if (unread) query.readAt = null;

    const items = await UserAlert.find(query)
      .sort({ createdAt: -1 })
      .limit(20)
      .lean();

    return res.json({
      ok: true,
      items: items.map((it) => ({
        id: it._id,
        type: it.type,
        message: it.message,
        createdAt: it.createdAt,
      })),
    });
  } catch (error) {
    console.error('User alerts list error:', error);
    return res.status(500).json({ ok: false, error: 'Сервер қатесі' });
  }
});

// POST /user/:id/alerts/:alertId/read
router.post('/:id/alerts/:alertId/read', async (req, res) => {
  try {
    const userId = String(req.params.id || '').trim();
    const alertId = String(req.params.alertId || '').trim();
    if (!isValidObjectId(userId) || !isValidObjectId(alertId)) {
      return res.status(400).json({ ok: false, error: 'Жарамды id керек' });
    }

    const alert = await UserAlert.findOneAndUpdate(
      { _id: alertId, userId },
      { $set: { readAt: new Date() } },
      { new: true }
    ).lean();

    if (!alert) {
      return res.status(404).json({ ok: false, error: 'Alert табылмады' });
    }

    return res.json({ ok: true });
  } catch (error) {
    console.error('User alert read error:', error);
    return res.status(500).json({ ok: false, error: 'Сервер қатесі' });
  }
});

module.exports = router;
