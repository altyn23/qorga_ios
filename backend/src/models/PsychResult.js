const mongoose = require('mongoose');

const psychResultSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    score: { type: Number, required: true },
    maxScore: { type: Number, required: true },
    stateText: { type: String, required: true },
    answers: [
      {
        questionId: { type: String, required: true }, // q1, q2, ...
        value: { type: Number, required: true },      // 1–4
      },
    ],
  },
  { timestamps: true }
);

module.exports = mongoose.model('PsychResult', psychResultSchema);
