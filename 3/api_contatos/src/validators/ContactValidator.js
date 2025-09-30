class ContactValidator {
  static validateContactData(data) {
    const errors = [];

    if (!data.nome || data.nome.trim() === '') {
      errors.push('Nome é obrigatório');
    }

    if (!data.telefone || data.telefone.trim() === '') {
      errors.push('Telefone é obrigatório');
    }

    if (data.email && !this.isValidEmail(data.email)) {
      errors.push('Email deve ter um formato válido');
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }

  static isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email.trim());
  }

  static validateRequiredFields(data, requiredFields) {
    const errors = [];
    
    requiredFields.forEach(field => {
      if (!data[field] || data[field].trim() === '') {
        errors.push(`${field} é obrigatório`);
      }
    });

    return {
      isValid: errors.length === 0,
      errors
    };
  }
}

module.exports = ContactValidator;