require "test_helper"

class PersonTest < ActiveSupport::TestCase
  test 'in_region' do
    result = Person.in_region('expected')
    assert result.map(&:name).sort == %w[Christie Wendell]
  end
end
