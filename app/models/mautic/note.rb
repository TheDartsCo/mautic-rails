module Mautic
  class Note < Model
    def self.all(connection, params = {})
      json = connection.request(:get, "api/#{endpoint}", params: params)
      json[field_name].map { |j| new(connection, j) }
    end
  end
end
