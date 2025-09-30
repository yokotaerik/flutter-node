const sqlite3 = require('sqlite3').verbose();
const path = require('path');

class Database {
  constructor() {
    this.db = null;
    this.init();
  }

  init() {
    const dbPath = path.join(__dirname, '..', '..', 'produtos.db');
    
    this.db = new sqlite3.Database(dbPath, (err) => {
      if (err) {
        console.error('Erro ao abrir o banco SQLite:', err);
      } else {
        console.log('SQLite aberto em:', dbPath);
        this.setupTables();
      }
    });
  }

  setupTables() {
    this.db.serialize(() => {
      // Criar tabela de produtos
      this.db.run(`
        CREATE TABLE IF NOT EXISTS produtos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          preco REAL NOT NULL,
          descricao TEXT,
          updated_at TEXT
        )
      `, (err) => {
        if (err) {
          console.error('Erro CREATE TABLE:', err);
        }
      });

      // Verificar e aplicar migração para coluna updated_at
      this.applyMigrations();
    });
  }

  applyMigrations() {
    this.db.all(`PRAGMA table_info(produtos)`, (err, cols) => {
      if (err) {
        console.error('Erro ao obter schema:', err);
        return;
      }
      
      const hasUpdatedAt = Array.isArray(cols) && cols.some(c => c.name === 'updated_at');

      if (!hasUpdatedAt) {
        console.log('Coluna "updated_at" ausente. Aplicando migração...');
        this.db.run(`ALTER TABLE produtos ADD COLUMN updated_at TEXT`, (err) => {
          if (err) {
            console.error('Erro ao adicionar coluna updated_at:', err.message);
          }
          this.updateExistingRecords();
        });
      } else {
        this.seedInitialData();
      }
    });
  }

  updateExistingRecords() {
    const now = new Date().toISOString();
    this.db.run(
      `UPDATE produtos SET updated_at = ? WHERE updated_at IS NULL OR updated_at = ''`,
      [now],
      (err) => {
        if (err) {
          console.error('Erro ao popular updated_at:', err);
        } else {
          console.log('Migração concluída: updated_at criada e populada.');
        }
        this.seedInitialData();
      }
    );
  }

  seedInitialData() {
    this.db.get('SELECT COUNT(*) AS count FROM produtos', (err, row) => {
      if (err) {
        console.error('Erro ao contar produtos:', err);
        return;
      }
      
      if ((row?.count ?? 0) === 0) {
        const now = new Date().toISOString();
        const stmt = this.db.prepare(
          'INSERT INTO produtos (nome, preco, descricao, updated_at) VALUES (?, ?, ?, ?)'
        );
        
        const initialProducts = [
          ['Camiseta Tech', 59.9, 'Camiseta 100% algodão premium', now],
          ['Mouse Gamer X', 129.0, 'RGB, 6 botões programáveis', now],
          ['Fone Bluetooth', 199.9, 'Cancelamento de ruído e estojo de carga', now],
        ];

        initialProducts.forEach(product => {
          stmt.run(product[0], product[1], product[2], product[3]);
        });
        
        stmt.finalize();
        console.log('Seed inicial inserido em produtos.db');
      }
    });
  }

  getConnection() {
    return this.db;
  }

  close() {
    if (this.db) {
      this.db.close((err) => {
        if (err) {
          console.error('Erro ao fechar banco:', err);
        } else {
          console.log('Conexão com banco fechada.');
        }
      });
    }
  }
}

module.exports = new Database();