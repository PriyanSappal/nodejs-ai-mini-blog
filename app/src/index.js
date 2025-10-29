const express = require('express');
const app = express();
const path = require('path');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const Post = require('./models/Post');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const axios = require('axios');
const expressLayouts = require('express-ejs-layouts');


const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY || null; // optional
const PUBLIC_IP = process.env.PUBLIC_IP


// basic rate limiter
const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 10, // limit each IP to 10 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});

if (process.env.NODE_ENV === 'production') {
  app.use('/api/', limiter);
} else {
  console.log('⚙️  Rate limiter disabled in development');
}

// Helmet - single call with demo-friendly settings
app.use(
  helmet({
    contentSecurityPolicy: false,
    crossOriginEmbedderPolicy: false,
    crossOriginOpenerPolicy: false,
  })
);
app.use(morgan('combined'));
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
// Diagnostic: log all incoming requests
app.use((req, res, next) => {
  console.log(`[${req.method}] ${req.url}`, req.body);
  next();
});
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(expressLayouts);
app.set('layout', 'layout'); // default layout file: views/layout.ejs
app.use('/public', express.static(path.join(__dirname, 'public')));
// Serve public folder
app.use(express.static(path.join(__dirname, 'public')));
// Serve node_modules (optional for dev, e.g., marked)
app.use('/node_modules', express.static(path.join(__dirname, 'node_modules')));

// connect to Mongo
if (!MONGO_URI) {
console.error('MONGO_URI not set. Exiting.');
process.exit(1);
}


mongoose.connect(MONGO_URI)
.then(() => console.log('Connected to MongoDB'))
.catch(err => { console.error(err); process.exit(1); });


// Home dashboard
app.get('/', async (req, res) => {
  // record a visit
  await mongoose.connection.db.collection('visits').insertOne({ at: new Date() });
  const postsCount = await Post.countDocuments();
  const visits = await (await mongoose.connection.db.collection('visits').countDocuments());
  const uptime = process.uptime();
  res.render('index', { postsCount, visits, uptime });
});


// Posts page
app.get('/posts', async (req, res) => {
const posts = await Post.find().sort({ createdAt: -1 }).lean();
res.render('posts', { posts });
});


// API: posts
app.get('/api/posts', async (req, res) => {
const posts = await Post.find().sort({ createdAt: -1 });
res.json(posts);
});


app.post('/api/posts', async (req, res) => {
  const { title, author, content } = req.body;
  console.log('[POST /api/posts] Received:', { title, author, content });

  if (!title || !content) {
    console.log('[POST /api/posts] Missing title/content');
    return res.status(400).json({ error: 'title and content required' });
  }

  try {
    const post = new Post({ title, author, content });
    const saved = await post.save();
    console.log('[POST /api/posts] Saved successfully:', saved);
    res.status(201).json(saved);
  } catch (err) {
    console.error('[POST /api/posts] Save failed:', err);
    res.status(500).json({ error: 'database error', details: err.message });
  }
});



// Simple visit counter
app.post('/api/visit', async (req, res) => {
await mongoose.connection.db.collection('visits').insertOne({ at: new Date() });
res.json({ ok: true });
});


// Health
app.get('/health', (req, res) => res.json({ status: 'ok' }));


// AI Assistant
app.post('/api/ai', async (req, res) => {
  console.log('Received body:', req.body);
  const prompt = req.body.prompt?.trim()

  if (!prompt) {
    return res.status(400).json({ text: 'Please provide a prompt.' });
  }

  // Fallback if no API key
  if (!process.env.OPENAI_API_KEY) {
    return res.json({ text: 'No API key set. Please configure one.' });
  }

  try {
    // Call OpenRouter API
    const resp = await axios.post(
      'https://openrouter.ai/api/v1/chat/completions',
      {
        model: 'openai/gpt-oss-20b:free',
        messages: [
        { role: 'user', content: prompt }
      ],
        max_tokens: 8000
      },
      {
        headers: {
          'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
          'HTTP-Referer': process.env.APP_URL || 'http://localhost:3000', // optional but required by OpenRouter
          'X-Title': 'DevOps Mini Blog' // optional app name for analytics
        }
      }
    );

    // Extract response text
    const text = resp.data.choices?.[0]?.message?.content || 'No reply from model.';
    res.json({ text });
  } catch (err) {
    console.error('AI error', err?.response?.data || err.message);
    res.status(500).json({ error: 'AI request failed' });
  }
});
// start server
app.listen(PORT, () => console.log(`App listening on port ${PORT}`));