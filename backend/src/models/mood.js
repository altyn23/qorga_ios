const mongoose = require('mongoose');

const moodSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true, // теперь обязателен
    },
    date: {
      type: Date,
      required: true,
    },
    mood: {
      type: String,
      enum: ['very_happy', 'happy', 'neutral', 'sad', 'angry'],
      required: true,
    },
    note: {
      type: String,
      default: '',
    },
  },
  { timestamps: true }
);

// Чтобы нельзя было сохранить 2 записи на один день у одного пользователя
moodSchema.index({ userId: 1, date: 1 }, { unique: true });

module.exports = mongoose.model('Mood', moodSchema);
