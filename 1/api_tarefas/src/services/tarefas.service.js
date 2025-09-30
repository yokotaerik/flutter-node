const fs = require('fs');
const path = require('path');

class TarefasService {
  constructor(filePath) {
    this.filePath = filePath;
  }

  lerTarefas() {
    try {
      const tarefasData = fs.readFileSync(this.filePath, 'utf8');
      return JSON.parse(tarefasData);
    } catch (error) {
      if (error.code === 'ENOENT') {
        this.escreverTarefas([]);
        return [];
      }
      throw new Error('Erro ao ler o arquivo de tarefas: ' + error.message);
    }
  }

  escreverTarefas(tarefas) {
    try {
      fs.writeFileSync(this.filePath, JSON.stringify(tarefas, null, 2));
    } catch (error) {
      throw new Error('Erro ao escrever no arquivo de tarefas: ' + error.message);
    }
  }

  adicionarTarefa(novaTarefa) {
    const tarefas = this.lerTarefas();
    tarefas.push(novaTarefa);
    this.escreverTarefas(tarefas);
    return novaTarefa;
  }

  atualizarTarefa(id, dadosAtualizacao) {
    const tarefas = this.lerTarefas();
    const index = tarefas.findIndex(tarefa => tarefa.id === id);
    
    if (index === -1) {
      return null;
    }
    
    const tarefaAtualizada = {
      ...tarefas[index],
      ...dadosAtualizacao,
      id
    };
    
    tarefas[index] = tarefaAtualizada;
    this.escreverTarefas(tarefas);
    
    return tarefaAtualizada;
  }

  removerTarefa(id) {
    const tarefas = this.lerTarefas();
    const index = tarefas.findIndex(tarefa => tarefa.id === id);
    
    if (index === -1) {
      return null;
    }
    
    const [tarefaRemovida] = tarefas.splice(index, 1);
    this.escreverTarefas(tarefas);
    
    return tarefaRemovida;
  }
}

module.exports = TarefasService;