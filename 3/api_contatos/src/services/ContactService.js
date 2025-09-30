const fs = require('fs');
const path = require('path');

class ContactService {
  constructor() {
    this.contactsFile = path.join(__dirname, '../../contatos.json');
  }

  readContacts() {
    try {
      if (!fs.existsSync(this.contactsFile)) {
        return [];
      }
      const data = fs.readFileSync(this.contactsFile, 'utf8');
      return JSON.parse(data);
    } catch (error) {
      console.error('Erro ao ler contatos:', error);
      return [];
    }
  }

  saveContacts(contacts) {
    try {
      fs.writeFileSync(this.contactsFile, JSON.stringify(contacts, null, 2));
      return true;
    } catch (error) {
      console.error('Erro ao salvar contatos:', error);
      return false;
    }
  }

  generateId() {
    return Date.now().toString();
  }

  getAllContacts() {
    return this.readContacts();
  }

  getContactById(id) {
    const contacts = this.readContacts();
    return contacts.find(contact => contact.id === id);
  }

  createContact(contactData) {
    const contacts = this.readContacts();
    const newContact = {
      id: this.generateId(),
      nome: contactData.nome.trim(),
      telefone: contactData.telefone.trim(),
      email: contactData.email ? contactData.email.trim() : '',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    contacts.push(newContact);
    
    if (this.saveContacts(contacts)) {
      return newContact;
    }
    throw new Error('Falha ao salvar contato');
  }

  updateContact(id, contactData) {
    const contacts = this.readContacts();
    const contactIndex = contacts.findIndex(contact => contact.id === id);
    
    if (contactIndex === -1) {
      return null;
    }

    const updatedContact = {
      ...contacts[contactIndex],
      nome: contactData.nome.trim(),
      telefone: contactData.telefone.trim(),
      email: contactData.email ? contactData.email.trim() : '',
      updatedAt: new Date().toISOString()
    };

    contacts[contactIndex] = updatedContact;
    
    if (this.saveContacts(contacts)) {
      return updatedContact;
    }
    throw new Error('Falha ao atualizar contato');
  }

  deleteContact(id) {
    const contacts = this.readContacts();
    const contactIndex = contacts.findIndex(contact => contact.id === id);
    
    if (contactIndex === -1) {
      return null;
    }

    const deletedContact = contacts[contactIndex];
    contacts.splice(contactIndex, 1);
    
    if (this.saveContacts(contacts)) {
      return deletedContact;
    }
    throw new Error('Falha ao excluir contato');
  }

  initializeContactsFile() {
    if (!fs.existsSync(this.contactsFile)) {
      this.saveContacts([]);
      console.log('Arquivo de contatos inicializado');
    }
  }
}

module.exports = ContactService;