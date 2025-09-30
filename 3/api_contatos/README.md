# API de Contatos

API REST para gerenciamento de contatos desenvolvida em Node.js com Express.

## Estrutura do Projeto

```
api_contatos/
├── src/
│   ├── controllers/
│   │   └── ContactController.js   # Controladores da API
│   ├── services/
│   │   └── ContactService.js      # Lógica de negócio
│   ├── validators/
│   │   └── ContactValidator.js    # Validações
│   ├── routes/
│   │   └── contactRoutes.js       # Definição das rotas
│   └── app.js                     # Configuração da aplicação
├── index.js                       # Ponto de entrada
├── package.json
├── .gitignore
└── README.md
```

## Instalação

1. Instale as dependências:
```bash
npm install
```

2. Para desenvolvimento (com reload automático):
```bash
npm install -g nodemon
npm run dev
```

3. Para produção:
```bash
npm start
```

## Endpoints da API

### GET /contatos
Retorna todos os contatos.

**Resposta:**
```json
{
  "success": true,
  "data": [...],
  "message": "Contatos recuperados com sucesso"
}
```

### GET /contatos/:id
Retorna um contato específico.

### POST /contatos
Cria um novo contato.

**Body:**
```json
{
  "nome": "Nome do contato",
  "telefone": "123456789",
  "email": "email@exemplo.com"
}
```

### PUT /contatos/:id
Atualiza um contato existente.

### DELETE /contatos/:id
Remove um contato.

## Funcionalidades

- ✅ CRUD completo de contatos
- ✅ Validação de dados
- ✅ Tratamento de erros
- ✅ Estrutura modular
- ✅ Separação de responsabilidades
- ✅ Suporte a CORS

## Tecnologias

- Node.js
- Express.js
- Body-parser
- CORS

## Scripts Disponíveis

- `npm start` - Executa a aplicação em modo produção
- `npm run dev` - Executa a aplicação em modo desenvolvimento com reload automático