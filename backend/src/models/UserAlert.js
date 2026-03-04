const mongoose = require('mongoose');

const userAlertSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    type: {
      type: String,
      enum: ['mood_risk'],
      required: true,
    },
    message: {
      type: String,
      required: true,
      trim: true,
    },
    riskWindowDays: {
      type: Number,
      default: 7,
    },
    badDaysCount: {
      type: Number,
      default: 0,
    },
    deliveredChannels: {
      inApp: {
        type: Boolean,
        default: true,
      },
      email: {
        type: Boolean,
        default: false,
      },
    },
    readAt: {
      type: Date,
      default: null,
      index: true,
    },
  },
  {
    timestamps: true,
  }
);

userAlertSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('UserAlert', userAlertSchema);
