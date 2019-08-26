module Mautic
  class Field < Model
    def self.endpoint
      'fields/contact'
    end

    def self.add_field(connection, names, opts)
      make_field = ->(name) { Field.new(connection, opts.merge(label: name.to_s, alias: name.to_s)) }
      if names.is_a?(Array)
        fields = names.map(&make_field)
        fields.each(&:create)
      else
        field = make_field.call(names)
        field.create
      end
    end

    def self.add_field_to_core(connection, names)
      opts = { group: 'core', type: 'text', object: 'lead' }
      add_field(connection, names, opts)
    end
  end
end
