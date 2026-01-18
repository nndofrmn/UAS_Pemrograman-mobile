const express = require('express');
const { getAllProducts, getProductById, searchProducts, createProduct, updateProduct, deleteProduct } = require('../controllers/productController');
const { authMiddleware } = require('../middleware');

const router = express.Router();

router.get('/', getAllProducts);
router.get('/search', searchProducts);
router.get('/:id', getProductById);
router.post('/', authMiddleware, createProduct);
router.put('/:id', authMiddleware, updateProduct);
router.delete('/:id', authMiddleware, deleteProduct);

module.exports = router;
