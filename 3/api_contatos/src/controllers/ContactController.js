const ContactService = require('../services/ContactService');
const ContactValidator = require('../validators/ContactValidator');

class ContactController {
  constructor() {
    this.contactService = new ContactService();
  }

  getAllContacts = (req, res) => {
    try {
      const contacts = this.contactService.getAllContacts();
      res.json({
        success: true,
        data: contacts,
        message: 'Contatos recuperados com sucesso'
      });
    } catch (error) {
      this.handleError(res, error);
    }
  };

  getContactById = (req, res) => {
    try {
      const { id } = req.params;
      const contact = this.contactService.getContactById(id);
      
      if (!contact) {
        return res.status(404).json({
          success: false,
          error: 'Contato não encontrado',
          message: `Contato com ID ${id} não existe`
        });
      }
      
      res.json({
        success: true,
        data: contact,
        message: 'Contato encontrado com sucesso'
      });
    } catch (error) {
      this.handleError(res, error);
    }
  };

  createContact = (req, res) => {
    try {
      const { nome, telefone, email } = req.body;
      
      const validation = ContactValidator.validateContactData({ nome, telefone, email });
      if (!validation.isValid) {
        return res.status(400).json({
          success: false,
          error: 'Dados inválidos',
          message: validation.errors.join(', ')
        });
      }
      
      const newContact = this.contactService.createContact({ nome, telefone, email });
      
      res.status(201).json({
        success: true,
        data: newContact,
        message: 'Contato criado com sucesso'
      });
    } catch (error) {
      this.handleError(res, error);
    }
  };

  updateContact = (req, res) => {
    try {
      const { id } = req.params;
      const { nome, telefone, email } = req.body;
      
      const validation = ContactValidator.validateContactData({ nome, telefone, email });
      if (!validation.isValid) {
        return res.status(400).json({
          success: false,
          error: 'Dados inválidos',
          message: validation.errors.join(', ')
        });
      }
      
      const updatedContact = this.contactService.updateContact(id, { nome, telefone, email });
      
      if (!updatedContact) {
        return res.status(404).json({
          success: false,
          error: 'Contato não encontrado',
          message: `Contato com ID ${id} não existe`
        });
      }
      
      res.json({
        success: true,
        data: updatedContact,
        message: 'Contato atualizado com sucesso'
      });
    } catch (error) {
      this.handleError(res, error);
    }
  };

  deleteContact = (req, res) => {
    try {
      const { id } = req.params;
      const deletedContact = this.contactService.deleteContact(id);
      
      if (!deletedContact) {
        return res.status(404).json({
          success: false,
          error: 'Contato não encontrado',
          message: `Contato com ID ${id} não existe`
        });
      }
      
      res.json({
        success: true,
        data: deletedContact,
        message: 'Contato excluído com sucesso'
      });
    } catch (error) {
      this.handleError(res, error);
    }
  };

  handleError = (res, error) => {
    console.error('Erro no controller:', error);
    res.status(500).json({
      success: false,
      error: 'Erro interno do servidor',
      message: error.message
    });
  };
}

module.exports = ContactController;