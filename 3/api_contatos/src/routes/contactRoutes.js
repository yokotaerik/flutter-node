const express = require('express');
const ContactController = require('../controllers/ContactController');

const router = express.Router();
const contactController = new ContactController();

// Rotas para contatos
router.get('/', contactController.getAllContacts);
router.get('/:id', contactController.getContactById);
router.post('/', contactController.createContact);
router.put('/:id', contactController.updateContact);
router.delete('/:id', contactController.deleteContact);

module.exports = router;