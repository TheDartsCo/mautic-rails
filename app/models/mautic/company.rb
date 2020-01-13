# frozen_string_literal: true

module Mautic
  class Company < Model
    def add_contact(contact)
      contact_id = contact.is_a?(Mautic::Contact) ? contact.id : contact
      @connection.request :post,
                          %(api/#{endpoint}/#{id}/contact/#{contact_id}/add)
    end

    def remove_contact(contact)
      contact_id = contact.is_a?(Mautic::Contact) ? contact.id : contact
      @connection.request :post,
                          %(api/#{endpoint}/#{id}/contact/#{contact_id}/remove)
    end

    def self.add_contact(connection: nil, company: nil, contact: nil)
      return if company.blank? || contact.blank?

      company = company.is_a?(self) ? company : find(connection, company)
      company.add_contact contact
    end

    def self.remove_contact(connection: nil, company: nil, contact: nil)
      return if company.blank? || contact.blank?

      company = company.is_a?(self) ? company : find(connection, company)
      company.remove_contact contact
    end
  end
end
