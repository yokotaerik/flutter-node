const express = require('express');
const path = require('path');
const TarefasService = require('../services/tarefas.service');
const TarefasController = require('../controllers/tarefas.controller');

const router = express.Router();

// Inicialização do serviço e controller
const tarefasService = new TarefasService(path.join(__dirname, '../../tarefas.json'));
const tarefasController = new TarefasController(tarefasService);

// Rotas
router.get('/', (req, res, next) => {
  try {
    tarefasController.listarTarefas(req, res);
  } catch (error) {
    next(error);
  }
});

router.post('/', (req, res, next) => {
  try {
    tarefasController.criarTarefa(req, res);
  } catch (error) {
    next(error);
  }
});

router.put('/:id', (req, res, next) => {
  try {
    tarefasController.atualizarTarefa(req, res);
  } catch (error) {
    next(error);
  }
});

router.delete('/:id', (req, res, next) => {
  try {
    tarefasController.removerTarefa(req, res);
  } catch (error) {
    next(error);
  }
});

module.exports = router;