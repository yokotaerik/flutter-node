# API de Produtos

API RESTful para gerenciamento de catálogo de produtos, construída com Node.js, Express e SQLite.

## 📁 Estrutura do Projeto

```
api_produtos/
├── src/
│   ├── config/
│   │   └── database.js          # Configuração e conexão SQLite
│   ├── controllers/
│   │   └── productController.js # Lógica de negócio dos endpoints
│   ├── middleware/
│   │   ├── logger.js           # Middleware de logging
│   │   └── validation.js       # Validações de entrada
│   ├── models/
│   │   └── Product.js          # Modelo e operações CRUD
│   └── routes/
│       └── products.js         # Definição das rotas
├── index.js                    # Arquivo principal do servidor
├── package.json
├── produtos.db                 # Banco SQLite
└── README.md
```

## 🚀 Como Executar

### Instalação
```bash
npm install
```

### Desenvolvimento (com nodemon)
```bash
npm run dev
```

### Produção
```bash
npm start
```

O servidor estará disponível em `http://localhost:3001`

## 📋 Endpoints da API

### Health Check
- **GET** `/health` - Verifica se a API está funcionando

### Produtos
- **GET** `/produtos` - Lista todos os produtos
- **GET** `/produtos/:id` - Busca produto por ID
- **POST** `/produtos` - Cria novo produto
- **PUT** `/produtos/:id` - Atualiza produto existente
- **DELETE** `/produtos/:id` - Remove produto

### Exemplos de Uso

#### Criar Produto
```bash
curl -X POST http://localhost:3001/produtos \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Produto Teste",
    "preco": 99.99,
    "descricao": "Descrição do produto"
  }'
```

#### Atualizar Produto
```bash
curl -X PUT http://localhost:3001/produtos/1 \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Produto Atualizado",
    "preco": 129.99
  }'
```

## 🏗️ Arquitetura

### Padrão MVC
- **Models**: Gerenciam dados e lógica de banco
- **Views**: Respostas JSON (API RESTful)
- **Controllers**: Lógica de negócio e coordenação

### Middleware
- **Logger**: Registra todas as requisições HTTP
- **Validation**: Valida dados de entrada antes do processamento
- **CORS**: Permite requisições de diferentes origens
- **Express JSON**: Parser para requisições JSON

### Separação de Responsabilidades
- **Database**: Configuração isolada do SQLite
- **Routes**: Definição clara de endpoints
- **Controllers**: Lógica de negócio centralizada
- **Models**: Operações de banco encapsuladas
- **Validation**: Validações robustas e reutilizáveis

## 🛠️ Melhorias Implementadas

1. **Estrutura Modular**: Código organizado em módulos específicos
2. **Validações Robustas**: Middleware dedicado para validação de entrada
3. **Tratamento de Erros**: Manejo adequado de exceções e erros
4. **Logging Melhorado**: Rastreamento detalhado de requisições
5. **Código Limpo**: Separação clara de responsabilidades
6. **Desenvolvimento**: Configuração com nodemon para hot reload

## 📝 Validações

### Produto
- **Nome**: Obrigatório, string, 2-100 caracteres
- **Preço**: Obrigatório, número >= 0, < 1.000.000
- **Descrição**: Opcional, string, máximo 500 caracteres
- **ID**: Número inteiro positivo (para operações específicas)

## 🗄️ Banco de Dados

- **SQLite**: Banco local para simplicidade
- **Tabela produtos**: id, nome, preco, descricao, updated_at
- **Auto-migração**: Sistema de migração automática
- **Seed inicial**: Dados de exemplo inseridos automaticamente