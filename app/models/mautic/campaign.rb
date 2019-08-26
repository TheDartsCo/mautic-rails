module Mautic
  class Campaign < ApplicationRecord

    def self.list_campaign_contacts(connection: connection, campaign: campaign)
      contacts = connection.request :get, %(api/campaigns/#{campaign}/contacts)
      return contacts["contacts"]
    end

  end
end
