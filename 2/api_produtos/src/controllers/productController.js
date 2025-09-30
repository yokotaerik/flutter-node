const Product = require('../models/Product');

class ProductController {
  constructor() {
    this.productModel = new Product();
  }

  // GET /produtos
  async getAllProducts(req, res) {
    try {
      const products = await this.productModel.findAll();
      res.json(products);
    } catch (error) {
      console.error('Erro ao buscar produtos:', error);
      res.status(500).json({ error: 'Erro ao buscar produtos' });
    }
  }

  // GET /produtos/:id
  async getProductById(req, res) {
    try {
      const { id } = req.params;
      const product = await this.productModel.findById(id);
      
      if (!product) {
        return res.status(404).json({ error: 'Produto não encontrado' });
      }
      
      res.json(product);
    } catch (error) {
      console.error('Erro ao buscar produto:', error);
      res.status(500).json({ error: 'Erro ao buscar produto' });
    }
  }

  // POST /produtos
  async createProduct(req, res) {
    try {
      const { nome, preco, descricao } = req.body;
      
      // Validação já feita pelo middleware
      const newProduct = await this.productModel.create({ nome, preco, descricao });
      res.status(201).json(newProduct);
    } catch (error) {
      console.error('Erro ao criar produto:', error);
      res.status(500).json({ error: 'Erro ao criar produto' });
    }
  }

  // PUT /produtos/:id
  async updateProduct(req, res) {
    try {
      const { id } = req.params;
      const updateData = req.body;

      // Validação já feita pelo middleware
      const updatedProduct = await this.productModel.update(id, updateData);
      res.json(updatedProduct);
    } catch (error) {
      if (error.message === 'Produto não encontrado') {
        return res.status(404).json({ error: 'Produto não encontrado' });
      }
      
      console.error('Erro ao atualizar produto:', error);
      res.status(500).json({ error: 'Erro ao atualizar produto' });
    }
  }

  // DELETE /produtos/:id
  async deleteProduct(req, res) {
    try {
      const { id } = req.params;
      const deletedProduct = await this.productModel.delete(id);
      
      res.json({ deleted: true, produto: deletedProduct });
    } catch (error) {
      if (error.message === 'Produto não encontrado') {
        return res.status(404).json({ error: 'Produto não encontrado' });
      }
      
      console.error('Erro ao excluir produto:', error);
      res.status(500).json({ error: 'Erro ao excluir produto' });
    }
  }

  // GET /health
  healthCheck(req, res) {
    res.json({ ok: true });
  }
}

module.exports = ProductController;