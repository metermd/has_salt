require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/pride'
require 'active_record'
require 'has_salt'

ActiveRecord::Base.establish_connection adapter:  'sqlite3',
                                        database: ':memory:'

class BaseTable < ActiveRecord::Base
end

class HasSaltTest < MiniTest::Test
  def setup
    capture_io do
      ActiveRecord::Schema.define(version: 1) do
        create_table :base_tables do |t|
          t.column :type,   :string

          t.column :salt,   :string
          t.column :sodium, :string
          t.column :salt16, :string, limit: 16
        end
      end
    end
  end

  def teardown
    capture_io do
      ActiveRecord::Base.connection.tables.each do |table|
        ActiveRecord::Base.connection.drop_table(table)
      end
    end
  end

  class DefaultSettings < BaseTable
    has_salt
  end

  # Just makes sure the module is included and can be instantiated.
  def test_basic_functionality
    u = DefaultSettings.create!
  end

  def test_defaults
    u = DefaultSettings.create!
    assert_equal HasSalt::DEFAULT_LENGTH, u.salt.size
  end

  def test_explicit_resalt
    u = DefaultSettings.create!
    assert_equal HasSalt::DEFAULT_LENGTH, u.salt.size
    salt1 = u.salt

    # This should not change the salt
    u.generate_salt
    assert_equal salt1, u.salt

    u.generate_salt!
    assert_equal HasSalt::DEFAULT_LENGTH, u.salt.size
    refute_equal salt1, u.salt
  end

  class OnlyTest < BaseTable
    has_salt only: -> { nevar! }
    has_salt column: :sodium, only: -> { yaaaase! }
    has_salt column: :salt16, only: :yaaaase!

    def nevar!
      false
    end

    def yaaaase!
      true
    end
  end

  def test_only
    u = OnlyTest.create!
    assert_equal nil, u.salt
    assert_equal HasSalt::DEFAULT_LENGTH, u.sodium.size
    refute_equal nil, u.salt16
  end

  class ExplicitName < BaseTable
    has_salt column: :sodium
  end

  def test_explicit_name
    u = ExplicitName.create!
    assert_equal nil, u.salt
    assert_equal HasSalt::DEFAULT_LENGTH, u.sodium.size
  end

  class ExplicitLength < BaseTable
    has_salt length: 15
  end

  def test_explicit_length
    u = ExplicitLength.create!
    assert_equal 15, u.salt.size
  end

  class ValidationBasedLength < BaseTable
    has_salt
    validates_length_of :salt, is: 81
  end

  def test_validation_based_length
    u = ValidationBasedLength.create!
    assert_equal 81, u.salt.size
  end

  class ValidationRangeBasedLength < BaseTable
    has_salt
    validates_length_of :salt, in: 5..100
  end

  def test_validation_range_based_length
    u = ValidationRangeBasedLength.create!
    assert_equal 64, u.salt.size
  end

  class SchemaBasedLength < BaseTable
    has_salt column: :salt16
  end

  def test_schema_based_length
    u = SchemaBasedLength.create!
    assert_equal 16, u.salt16.size
  end

end
