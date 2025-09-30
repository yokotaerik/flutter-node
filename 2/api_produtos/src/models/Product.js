const database = require('../config/database');

class Product {
  constructor() {
    this.db = database.getConnection();
  }

  // Buscar todos os produtos
  async findAll() {
    return new Promise((resolve, reject) => {
      this.db.all(
        'SELECT id, nome, preco, descricao, updated_at FROM produtos ORDER BY id DESC',
        (err, rows) => {
          if (err) {
            reject(err);
          } else {
            resolve(rows);
          }
        }
      );
    });
  }

  // Buscar produto por ID
  async findById(id) {
    return new Promise((resolve, reject) => {
      this.db.get(
        'SELECT id, nome, preco, descricao, updated_at FROM produtos WHERE id = ?',
        [id],
        (err, row) => {
          if (err) {
            reject(err);
          } else {
            resolve(row);
          }
        }
      );
    });
  }

  // Criar novo produto
  async create(productData) {
    const { nome, preco, descricao = '' } = productData;
    const now = new Date().toISOString();

    return new Promise((resolve, reject) => {
      this.db.run(
        'INSERT INTO produtos (nome, preco, descricao, updated_at) VALUES (?, ?, ?, ?)',
        [nome.trim(), Number(preco), descricao, now],
        function (err) {
          if (err) {
            reject(err);
          } else {
            const id = this.lastID;
            // Retornar o produto criado
            resolve({
              id,
              nome: nome.trim(),
              preco: Number(preco),
              descricao,
              updated_at: now
            });
          }
        }
      );
    });
  }

  // Atualizar produto
  async update(id, productData) {
    const existingProduct = await this.findById(id);
    if (!existingProduct) {
      throw new Error('Produto não encontrado');
    }

    const nome = productData.nome !== undefined ? String(productData.nome).trim() : existingProduct.nome;
    const preco = productData.preco !== undefined ? Number(productData.preco) : Number(existingProduct.preco);
    const descricao = productData.descricao !== undefined ? String(productData.descricao) : existingProduct.descricao;
    const now = new Date().toISOString();

    return new Promise((resolve, reject) => {
      this.db.run(
        'UPDATE produtos SET nome = ?, preco = ?, descricao = ?, updated_at = ? WHERE id = ?',
        [nome, preco, descricao, now, id],
        function (err) {
          if (err) {
            reject(err);
          } else {
            resolve({
              id: Number(id),
              nome,
              preco,
              descricao,
              updated_at: now
            });
          }
        }
      );
    });
  }

  // Deletar produto
  async delete(id) {
    const existingProduct = await this.findById(id);
    if (!existingProduct) {
      throw new Error('Produto não encontrado');
    }

    return new Promise((resolve, reject) => {
      this.db.run(
        'DELETE FROM produtos WHERE id = ?',
        [id],
        function (err) {
          if (err) {
            reject(err);
          } else {
            resolve(existingProduct);
          }
        }
      );
    });
  }

  // Validar dados do produto
  validateProductData(productData) {
    const errors = [];
    const { nome, preco } = productData;

    if (typeof nome !== 'string' || !nome.trim()) {
      errors.push('nome inválido');
    }

    if (Number.isNaN(Number(preco))) {
      errors.push('preco inválido');
    }

    return errors;
  }
}

module.exports = Product;