const mongoose = require('mongoose');

const userSchema = mongoose.Schema(
  {
    phone: {
      type: String,
      required: true,
      unique: true,
    },
    email: {
      type: String,
      unique: true,
      sparse: true,
    },
    name: {
      type: String,
      required: true,
    },
    fcmTokens: {
      type: [String],
      default: [],
    },
    role: {
      type: String,
      enum: ['USER', 'ADMIN'],
      default: 'USER',
    }
  },
  { timestamps: true }
);

const User = mongoose.model('User', userSchema);
module.exports = User;
