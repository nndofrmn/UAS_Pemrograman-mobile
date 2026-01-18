const db = require('../database');

exports.createOrder = (req, res) => {
  const { items } = req.body;
  const userId = req.user.id;
  const orderId = 'o' + Date.now();
  let totalPrice = 0;

  const productIds = items.map(i => i.productId);
  const placeholders = productIds.map(() => '?').join(',');

  db.all(`SELECT * FROM products WHERE id IN (${placeholders})`, productIds, (err, products) => {
    if (err) return res.status(500).json({ error: 'Error' });

    items.forEach(item => {
      const product = products.find(p => p.id === item.productId);
      if (product) totalPrice += product.price * item.quantity;
    });

    db.run(
      `INSERT INTO orders (id, userId, totalPrice, status) VALUES (?, ?, ?, ?)`,
      [orderId, userId, totalPrice, 'pending'],
      (err) => {
        items.forEach((item, idx) => {
          const itemId = 'oi' + Date.now() + idx;
          const product = products.find(p => p.id === item.productId);
          db.run(
            `INSERT INTO order_items (id, orderId, productId, quantity, price) VALUES (?, ?, ?, ?, ?)`,
            [itemId, orderId, item.productId, item.quantity, product?.price || 0],
            () => {
              db.run(`UPDATE products SET stock = stock - ? WHERE id = ?`, [item.quantity, item.productId]);
            }
          );
        });
        res.status(201).json({ id: orderId, totalPrice, status: 'pending' });
      }
    );
  });
};

exports.getUserOrders = (req, res) => {
  db.all(`SELECT * FROM orders WHERE userId = ? ORDER BY createdAt DESC`, [req.user.id], (err, orders) => {
    res.json(orders || []);
  });
};

exports.getOrderById = (req, res) => {
  db.get(`SELECT * FROM orders WHERE id = ? AND userId = ?`, [req.params.id, req.user.id], (err, order) => {
    if (!order) return res.status(404).json({ error: 'Not found' });
    db.all(`SELECT oi.*, p.name FROM order_items oi JOIN products p ON oi.productId = p.id WHERE oi.orderId = ?`, [req.params.id], (err, items) => {
      order.items = items;
      res.json(order);
    });
  });
};

exports.cancelOrder = (req, res) => {
  db.get(`SELECT * FROM orders WHERE id = ? AND userId = ?`, [req.params.id, req.user.id], (err, order) => {
    if (!order || order.status !== 'pending') {
      return res.status(400).json({ error: 'Cannot cancel' });
    }

    db.all(`SELECT * FROM order_items WHERE orderId = ?`, [req.params.id], (err, items) => {
      items?.forEach(item => {
        db.run(`UPDATE products SET stock = stock + ? WHERE id = ?`, [item.quantity, item.productId]);
      });

      db.run(`UPDATE orders SET status = 'cancelled' WHERE id = ?`, [req.params.id], () => {
        res.json({ message: 'Cancelled' });
      });
    });
  });
};
