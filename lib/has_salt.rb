require 'securerandom'

module HasSalt
  DEFAULT_LENGTH = 64
  module ClassMethods
    INFINITY = 1.0 / 0.0

    def has_salt(only: nil, column: nil, length: nil, size: nil)
      only   ||= -> { true }
      column ||= :salt

      # Size override
      fail "don't pass both :size and :length" if size && length
      length ||= size

      # Allow passing in strings
      column = column.to_sym
      plural_column = column.to_s.pluralize

      # Handle `only: :predicate?` argument.
      # With correct binding via function invocation.
      only = ->(symbol) { -> { send(symbol) } }.(only) if only.is_a?(Symbol)

      generate_salt = -> (length) do
        raw = SecureRandom.hex((length / 2.0) + 1)
        raw[0...length]
      end

      # Gets the restricted range based on AR validations
      validation_salt_length = ->(column) do
        minmax = [0.0, INFINITY]

        length_validators = validators_on(column).select do |v|
          v.is_a?(ActiveModel::Validations::LengthValidator)
        end

        length_validators.each do |validator|
          options = validator.options

          # Explicitly set?  Done.
          minmax = ([options[:is].to_f] * 2) and break if options[:is]

          # Adjust bounds.
          minmax = [ [minmax[0], options[:minimum] || 0].max.to_f,
                     [minmax[1], options[:maximum] || INFINITY].min.to_f ]
        end

        minmax
      end

      schema_salt_length = ->(column) do
        [0.0, (columns_hash[column.to_s].limit || INFINITY).to_f]
      end

      calculated_salt_length = ->(column) do
        # Explicitly passed length
        return length unless length.nil?

        # Result from validations with :is
        from_validations = validation_salt_length.(column)
        return from_validations.first.to_i if from_validations.uniq.size == 1

        # Result from schema with :limit
        from_schema = schema_salt_length.(column)
        return from_schema.first.to_i if from_schema.uniq.size == 1

        minmax = [[from_validations[0], from_schema[0]].max,
                  [from_validations[1], from_schema[1]].min ]

        # OK, now let's be reasonable:
        length = DEFAULT_LENGTH
        length = minmax[0] if length < minmax[0]
        length = minmax[1] if length > minmax[1]
        length
      end

      # Updates regardless
      define_method("generate_#{column}!") do
        send("#{column}=", generate_salt.(calculated_salt_length.(column)))
      end


      # Updates if changed.
      define_method("generate_#{column}") do
        if send(column).blank? && instance_exec(&only)
          send("generate_#{column}!")
        end
      end

      before_validation "generate_#{column}".to_sym
    end
  end

  def self.included(cls)
    cls.send(:extend, ClassMethods)
  end
end

if defined?(ActiveRecord::Base)
  class << ActiveRecord::Base
    def has_salt(*args, **kw)
      include HasSalt
      has_salt(*args, **kw)
    end
  end
end
