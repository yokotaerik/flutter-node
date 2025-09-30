const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');

const TarefasService = require('./src/services/tarefas.service');
const TarefasController = require('./src/controllers/tarefas.controller');
const tarefasRoutes = require('./src/routes/tarefas.routes');
const { errorHandler } = require('./src/middleware/error.middleware');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

const tarefasService = new TarefasService(path.join(__dirname, 'tarefas.json'));
const tarefasController = new TarefasController(tarefasService);

app.use('/tarefas', tarefasRoutes);

app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
