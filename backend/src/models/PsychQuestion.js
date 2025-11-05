const mongoose = require('mongoose');

const psychQuestionSchema = new mongoose.Schema(
  {
    text: { type: String, required: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('PsychQuestion', psychQuestionSchema);
