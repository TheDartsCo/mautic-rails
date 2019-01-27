module Mautic
  class Stage < Model
    def add_contact(contact)
      contact_id = contact.is_a?(Mautic::Contact) ? contact.id : contact
      @connection.request :post, %(api/#{endpoint}/#{id}/contact/#{contact_id}/add)
    end

    def remove_contact(contact)
      contact_id = contact.is_a?(Mautic::Contact) ? contact.id : contact
      @connection.request :post, %(api/#{endpoint}/#{id}/contact/#{contact_id}/remove)
    end

    def self.add_contact(stage: nil, contact: nil)
      return if stage.blank? || contact.blank?
      stage = stage.is_a?(self) ? stage : self.find(stage)
      stage.add_contact contact
    end

    def self.remove_contact(stage: nil, contact: nil)
      return if stage.blank? || contact.blank?
      stage = stage.is_a?(self) ? stage : self.find(stage)
      stage.remove_contact contact
    end
  end
end
