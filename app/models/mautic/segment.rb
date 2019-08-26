module Mautic
  class Segment < Model

    #セグメントでのfindの挙動が他と違うので、オーバーライド
    def self.find(connection: nil, segment: nil)
      segment = connection.request :get, %(api/segments/#{segment})
      return segment
    end

    def self.add_contact(connection: nil, segment: nil, contact: nil)
      connection.request :post, %(api/segments/#{segment}/contact/#{contact}/add)
    end

    def self.remove_contact(connection: nil, segment: nil, contact: nil)
      connection.request :post, %(api/segments/#{segment}/contact/#{contact}/remove)
    end

  end
end
