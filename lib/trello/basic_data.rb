require 'trello/string'

module Trello
  class BasicData
    include ActiveModel::Validations
    include ActiveModel::Dirty
    include ActiveModel::Serializers::JSON

    attr_reader :id

    class << self
      def find(path, id)
        Client.get("/#{path}/#{id}").json_into(self)
      end
    end

    def self.register_attributes(*names)
      # Defines the attribute getter and setters.
      class_eval do
        define_method :attributes, do
          @attributes ||= names.inject({}) { |hash,k| hash.merge(k.to_sym => nil) }
        end

        names.each do |key|
          define_method(:"#{key}") { @attributes[key] }

          define_method :"#{key}=" do |val|
            send(:"#{key}_will_change!") unless val == @attributes[key]
            @attributes[key] = val
          end
        end
        define_attribute_methods names
      end
    end

    def initialize(fields = {})
      update_fields(fields)
    end

    def update_fields(fields)
      raise NotImplementedError, "#{self.class} does not implement update_fields."
    end

    # Refresh the contents of our object.
    def refresh!
      self.class.find(id)
    end

    # Two objects are equal if their _id_ methods are equal.
    def ==(other)
      id == other.id
    end
  end
end
