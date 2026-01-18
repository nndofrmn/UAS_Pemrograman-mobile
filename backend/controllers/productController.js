const db = require('../database');

exports.getAllProducts = (req, res) => {
  db.all(`SELECT * FROM products`, (err, products) => {
    res.json(products || []);
  });
};

exports.getProductById = (req, res) => {
  db.get(`SELECT * FROM products WHERE id = ?`, [req.params.id], (err, product) => {
    if (!product) return res.status(404).json({ error: 'Not found' });
    res.json(product);
  });
};

exports.searchProducts = (req, res) => {
  const q = `%${req.query.q || ''}%`;
  db.all(`SELECT * FROM products WHERE name LIKE ? OR category LIKE ?`, [q, q], (err, products) => {
    res.json(products || []);
  });
};

exports.createProduct = (req, res) => {
  const { name, category, size, stock, price, description, imageUrl } = req.body;
  const id = 'p' + Date.now();
  db.run(
    `INSERT INTO products (id, name, category, size, stock, price, description, imageUrl) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [id, name, category, size, stock, price, description, imageUrl],
    (err) => {
      res.status(201).json({ id, name, category, size, stock, price });
    }
  );
};

exports.updateProduct = (req, res) => {
  const { name, category, size, stock, price, description, imageUrl } = req.body;
  db.run(
    `UPDATE products SET name = ?, category = ?, size = ?, stock = ?, price = ?, description = ?, imageUrl = ? WHERE id = ?`,
    [name, category, size, stock, price, description, imageUrl, req.params.id],
    (err) => {
      res.json({ message: 'Updated' });
    }
  );
};

exports.deleteProduct = (req, res) => {
  db.run(`DELETE FROM products WHERE id = ?`, [req.params.id], (err) => {
    res.json({ message: 'Deleted' });
  });
};
