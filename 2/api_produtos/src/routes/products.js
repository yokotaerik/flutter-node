const express = require('express');
const ProductController = require('../controllers/productController');
const { 
  validateCreateProduct, 
  validateUpdateProduct, 
  validateProductId 
} = require('../middleware/validation');

const router = express.Router();
const productController = new ProductController();

// Rota de health check
router.get('/health', (req, res) => productController.healthCheck(req, res));

// Rotas de produtos
router.get('/produtos', (req, res) => productController.getAllProducts(req, res));
router.get('/produtos/:id', validateProductId, (req, res) => productController.getProductById(req, res));
router.post('/produtos', validateCreateProduct, (req, res) => productController.createProduct(req, res));
router.put('/produtos/:id', validateProductId, validateUpdateProduct, (req, res) => productController.updateProduct(req, res));
router.delete('/produtos/:id', validateProductId, (req, res) => productController.deleteProduct(req, res));

module.exports = router;