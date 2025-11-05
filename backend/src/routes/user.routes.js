const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const User = require('../models/user'); // путь к модели

// PUT /user/:id — обновить данные профиля
router.put('/:id', async (req, res) => {
  try {
    const { name, email, oldPassword, password } = req.body;
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({ message: 'Пайдаланушы табылмады' });
    }

    // обновление имени и email
    if (name) user.displayName = name;
    if (email) user.email = email;

    // если пришёл новый пароль — проверяем старый
    if (password) {
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
      },
    });
  } catch (error) {
    console.error('User update error:', error);
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});

module.exports = router;
