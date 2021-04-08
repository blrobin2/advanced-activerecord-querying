require "test_helper"

class LocationTest < ActiveSupport::TestCase
  test 'in_region' do
    result = Location.in_region('expected')
    assert result.map(&:name).sort == %w[in-expected-region-one in-expected-region-two]
  end
end
