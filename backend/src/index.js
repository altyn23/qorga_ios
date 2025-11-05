require('dotenv').config();
const express = require('express');
const cookieParser = require('cookie-parser');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const userRoutes = require('./routes/user.routes');

const { connectDB } = require('./config/db');

const authRoutes = require('./routes/auth.routes');
const contentRoutes = require('./routes/content.routes');
const moodRoutes = require('./routes/mood.routes');
const psychologyRoutes = require('./routes/psychology.routes');
const chatRoutes = require('./routes/chat.routes');


const app = express();

app.use(express.json());
app.use(cookieParser());
app.use(cors({
  origin: (process.env.CLIENT_ORIGIN || 'http://localhost:5173').split(','),
  credentials: true
}));
app.use(helmet());
app.use(morgan('dev'));

app.get('/health', (req, res) => res.json({ ok: true, uptime: process.uptime() }));

app.use('/auth', authRoutes);
app.use('/content', contentRoutes);
app.use('/mood', moodRoutes);
app.use('/user', userRoutes);
app.use('/psychology', psychologyRoutes);
app.use('/chat', chatRoutes);


const PORT = process.env.PORT || 4000;
connectDB(process.env.MONGODB_URI)
  .then(() => app.listen(PORT, () => console.log(`🚀 http://localhost:${PORT}`)))
  .catch(err => {
    console.error('❌ Mongo connect error:', err.message);
    process.exit(1);
  });
