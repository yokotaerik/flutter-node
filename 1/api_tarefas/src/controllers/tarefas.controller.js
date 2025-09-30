class TarefasController {
  constructor(tarefasService) {
    this.tarefasService = tarefasService;
  }

  listarTarefas(req, res) {
    const tarefas = this.tarefasService.lerTarefas();
    res.json(tarefas);
  }

  criarTarefa(req, res) {
    const novaTarefa = {
      id: Date.now().toString(),
      titulo: req.body.titulo,
      descricao: req.body.descricao,
      concluida: false,
      dataCriacao: new Date().toISOString()
    };
    
    this.tarefasService.adicionarTarefa(novaTarefa);
    res.status(201).json(novaTarefa);
  }

  atualizarTarefa(req, res) {
    const id = req.params.id;
    const tarefaAtualizada = this.tarefasService.atualizarTarefa(id, req.body);
    
    if (!tarefaAtualizada) {
      return res.status(404).json({ error: 'Tarefa não encontrada' });
    }
    
    res.json(tarefaAtualizada);
  }

  removerTarefa(req, res) {
    const id = req.params.id;
    const tarefaRemovida = this.tarefasService.removerTarefa(id);
    
    if (!tarefaRemovida) {
      return res.status(404).json({ error: 'Tarefa não encontrada' });
    }
    
    res.json(tarefaRemovida);
  }
}

module.exports = TarefasController;