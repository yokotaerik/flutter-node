/**
 * Middleware de validação para dados de entrada
 */

// Validação para criação de produto
const validateCreateProduct = (req, res, next) => {
  const { nome, preco } = req.body;
  const errors = [];

  // Validar nome
  if (!nome || typeof nome !== 'string' || !nome.trim()) {
    errors.push('Nome é obrigatório e deve ser uma string não vazia');
  } else if (nome.trim().length < 2) {
    errors.push('Nome deve ter pelo menos 2 caracteres');
  } else if (nome.trim().length > 100) {
    errors.push('Nome deve ter no máximo 100 caracteres');
  }

  // Validar preço
  if (preco === undefined || preco === null) {
    errors.push('Preço é obrigatório');
  } else if (typeof preco !== 'number' || Number.isNaN(Number(preco))) {
    errors.push('Preço deve ser um número válido');
  } else if (Number(preco) < 0) {
    errors.push('Preço deve ser maior ou igual a zero');
  } else if (Number(preco) > 999999.99) {
    errors.push('Preço deve ser menor que 1.000.000');
  }

  // Validar descrição (opcional)
  if (req.body.descricao !== undefined) {
    if (typeof req.body.descricao !== 'string') {
      errors.push('Descrição deve ser uma string');
    } else if (req.body.descricao.length > 500) {
      errors.push('Descrição deve ter no máximo 500 caracteres');
    }
  }

  if (errors.length > 0) {
    return res.status(400).json({ 
      error: 'Dados inválidos',
      errors 
    });
  }

  next();
};

// Validação para atualização de produto
const validateUpdateProduct = (req, res, next) => {
  const { nome, preco, descricao } = req.body;
  const errors = [];

  // Se nenhum campo foi fornecido
  if (nome === undefined && preco === undefined && descricao === undefined) {
    return res.status(400).json({
      error: 'Pelo menos um campo deve ser fornecido para atualização',
      errors: ['Forneça pelo menos um dos campos: nome, preco, descricao']
    });
  }

  // Validar nome se fornecido
  if (nome !== undefined) {
    if (typeof nome !== 'string' || !nome.trim()) {
      errors.push('Nome deve ser uma string não vazia');
    } else if (nome.trim().length < 2) {
      errors.push('Nome deve ter pelo menos 2 caracteres');
    } else if (nome.trim().length > 100) {
      errors.push('Nome deve ter no máximo 100 caracteres');
    }
  }

  // Validar preço se fornecido
  if (preco !== undefined) {
    if (typeof preco !== 'number' || Number.isNaN(Number(preco))) {
      errors.push('Preço deve ser um número válido');
    } else if (Number(preco) < 0) {
      errors.push('Preço deve ser maior ou igual a zero');
    } else if (Number(preco) > 999999.99) {
      errors.push('Preço deve ser menor que 1.000.000');
    }
  }

  // Validar descrição se fornecida
  if (descricao !== undefined) {
    if (typeof descricao !== 'string') {
      errors.push('Descrição deve ser uma string');
    } else if (descricao.length > 500) {
      errors.push('Descrição deve ter no máximo 500 caracteres');
    }
  }

  if (errors.length > 0) {
    return res.status(400).json({ 
      error: 'Dados inválidos',
      errors 
    });
  }

  next();
};

// Validação de ID
const validateProductId = (req, res, next) => {
  const { id } = req.params;
  
  if (!id || Number.isNaN(Number(id)) || Number(id) <= 0) {
    return res.status(400).json({
      error: 'ID inválido',
      errors: ['ID deve ser um número inteiro positivo']
    });
  }

  next();
};

module.exports = {
  validateCreateProduct,
  validateUpdateProduct,
  validateProductId
};