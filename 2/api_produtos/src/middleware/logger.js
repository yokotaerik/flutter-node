/**
 * Middleware de logging para registrar requisições HTTP
 */
const logger = (req, res, next) => {
  const timestamp = new Date().toISOString();
  const method = req.method;
  const url = req.url;
  const userAgent = req.get('User-Agent') || 'Unknown';
  
  console.log(`[${timestamp}] ${method} ${url} - ${userAgent}`);
  
  // Log do corpo da requisição para POST/PUT (opcional, útil para debug)
  if ((method === 'POST' || method === 'PUT') && req.body) {
    console.log(`[${timestamp}] Body:`, JSON.stringify(req.body, null, 2));
  }
  
  next();
};

module.exports = logger;