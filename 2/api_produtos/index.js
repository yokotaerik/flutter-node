const express = require('express');
const cors = require('cors');

// Importar configuração do banco (inicializa automaticamente)
require('./src/config/database');

// Importar middleware e rotas
const logger = require('./src/middleware/logger');
const productRoutes = require('./src/routes/products');

const app = express();
const PORT = process.env.PORT || 3001;

// Middlewares
app.use(cors());
app.use(express.json());
app.use(logger);

// Rotas
app.use('/', productRoutes);

// Configuração e inicialização do servidor
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`API rodando em http://localhost:${PORT}`);
});

// Tratamento de erros do servidor
server.on('error', (err) => {
  console.error('Falha ao subir o servidor:', err.code || err.message, err);
  if (err.code === 'EADDRINUSE') {
    console.error(`Porta ${PORT} já está em uso. Finalize o processo que a ocupa.`);
    console.error(`Dica: lsof -nP -iTCP:${PORT} -sTCP:LISTEN`);
  }
  process.exit(1);
});

// Tratamento de exceções não capturadas
process.on('uncaughtException', (err) => {
  console.error('UncaughtException:', err);
});

process.on('unhandledRejection', (reason, p) => {
  console.error('UnhandledRejection:', reason, 'em', p);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('Encerrando por SIGINT...');
  server.close(() => {
    // Fechar conexão com banco
    const database = require('./src/config/database');
    database.close();
    process.exit(0);
  });
});
