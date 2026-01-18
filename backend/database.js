const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

const dbPath = process.env.DATABASE_PATH || './database/app.db';
const dbDir = path.dirname(dbPath);

if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Database error:', err);
  } else {
    console.log('✅ Connected to SQLite database');
    initializeDatabase();
  }
});

const initializeDatabase = () => {
  db.run(`CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'user',
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS products (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    size TEXT NOT NULL,
    stock INTEGER NOT NULL,
    price INTEGER NOT NULL,
    description TEXT,
    imageUrl TEXT
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS orders (
    id TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    totalPrice INTEGER NOT NULL,
    status TEXT DEFAULT 'pending',
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES users(id)
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS order_items (
    id TEXT PRIMARY KEY,
    orderId TEXT NOT NULL,
    productId TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    price INTEGER NOT NULL,
    FOREIGN KEY (orderId) REFERENCES orders(id),
    FOREIGN KEY (productId) REFERENCES products(id)
  )`);

  insertDemoData();
  insertDemoUsers();
};

const insertDemoData = () => {
  db.get('SELECT COUNT(*) as count FROM products', (err, row) => {
    if (err || !row || row.count > 0) return;

    const products = [
      { id: 'p1', name: 'Kaos Vintage', category: 'Kaos', size: 'M', stock: 5, price: 70000, description: 'Kaos vintage berkualitas', imageUrl: 'https://picsum.photos/seed/p1/400/400' },
      { id: 'p2', name: 'Jaket Denim', category: 'Jaket', size: 'L', stock: 2, price: 150000, description: 'Jaket denim second', imageUrl: 'https://picsum.photos/seed/p2/400/400' },
      { id: 'p3', name: 'Celana Chino', category: 'Celana', size: 'M', stock: 8, price: 90000, description: 'Celana chino warna khaki', imageUrl: 'https://picsum.photos/seed/p3/400/400' },
      { id: 'p4', name: 'Sweater Rajut', category: 'Sweater', size: 'L', stock: 4, price: 120000, description: 'Sweater rajut hangat', imageUrl: 'https://picsum.photos/seed/p4/400/400' },
      { id: 'p5', name: 'Kemeja Flanel', category: 'Kemeja', size: 'XL', stock: 3, price: 85000, description: 'Kemeja flanel nyaman', imageUrl: 'https://picsum.photos/seed/p5/400/400' }
    ];

    products.forEach(p => {
      db.run(`INSERT INTO products (id, name, category, size, stock, price, description, imageUrl) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [p.id, p.name, p.category, p.size, p.stock, p.price, p.description, p.imageUrl]);
    });

    console.log('✅ Demo data inserted');
  });
};

const insertDemoUsers = () => {
  db.get('SELECT COUNT(*) as count FROM users', (err, row) => {
    if (err || !row || row.count > 0) return;

    const bcrypt = require('bcryptjs');
    const users = [
      { id: 'u1', name: 'Admin User', email: 'admin@thriftstock.com', password: 'admin123', role: 'admin' },
      { id: 'u2', name: 'John Doe', email: 'john@example.com', password: 'pass123', role: 'user' }
    ];

    users.forEach(u => {
      bcrypt.hash(u.password, 10, (err, hash) => {
        db.run(`INSERT INTO users (id, name, email, password, role) VALUES (?, ?, ?, ?, ?)`,
          [u.id, u.name, u.email, hash, u.role]);
      });
    });

    console.log('✅ Demo users inserted');
  });
};

module.exports = db;
