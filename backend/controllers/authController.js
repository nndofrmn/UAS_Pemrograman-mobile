const db = require('../database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.register = (req, res) => {
  const { name, email, password } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Missing fields' });
  }

  bcrypt.hash(password, 10, (err, hash) => {
    const id = Date.now().toString();
    db.run(
      `INSERT INTO users (id, name, email, password, role) VALUES (?, ?, ?, ?, ?)`,
      [id, name, email, hash, 'user'],
      (err) => {
        if (err) {
          return res.status(400).json({ error: 'Email exists' });
        }
        const token = jwt.sign({ id, email, role: 'user' }, process.env.JWT_SECRET, { expiresIn: '7d' });
        res.status(201).json({ user: { id, name, email, role: 'user' }, token });
      }
    );
  });
};

exports.login = (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Missing fields' });
  }

  db.get(`SELECT * FROM users WHERE email = ?`, [email], (err, user) => {
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    bcrypt.compare(password, user.password, (err, valid) => {
      if (!valid) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }
      const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, process.env.JWT_SECRET, { expiresIn: '7d' });
      res.json({ user: { id: user.id, name: user.name, email: user.email, role: user.role }, token });
    });
  });
};

exports.getMe = (req, res) => {
  db.get(`SELECT id, name, email, role FROM users WHERE id = ?`, [req.user.id], (err, user) => {
    res.json(user);
  });
};
