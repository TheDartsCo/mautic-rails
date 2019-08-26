module Mautic
  class Contact < Model
    alias_attribute :first_name, :firstname
    alias_attribute :last_name, :lastname
    def self.in(connection)
      Proxy.new(connection, endpoint, default_params: { search: '!is:anonymous' })
    end

    def name
      "#{firstname} #{lastname}"
    end

    def assign_attributes(source = {})
      super

      return unless source

      self.attributes = {
        tags: (source['tags'] || []).collect { |t| Mautic::Tag.new(@connection, t) },
        doNotContact: source['doNotContact']
      }
    end

    def add_dnc(comments: '')
      begin
        @connection.request(:post, "api/contacts/#{id}/dnc/email/add",
                            body: { comments: comments })
        clear_changes
      rescue ValidationError => e
        self.errors = e.errors
      end

      errors.blank?
    end

    def remove_dnc
      begin
        @connection.request(:post, "api/contacts/#{id}/dnc/email/remove",
                            body: {})
        clear_changes
      rescue ValidationError => e
        self.errors = e.errors
      end

      errors.blank?
    end

    def dnc?
      doNotContact.present?
    end

    def self.segment_memberships(connection: nil, contact: nil)
      contact_id = contact.is_a?(Mautic::Contact) ? contact.id : contact
      segments = connection.request(:get, %(api/contacts/#{contact_id}/segments))['lists'].values
      segments
    end

    def segment_memberships
      @connection.request(:get, %(api/contacts/#{id}/segments))['lists'].values
    end
  end
end
