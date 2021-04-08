require "test_helper"

class LocationTest < ActiveSupport::TestCase
  test 'in_region' do
    region = create(:region, name: 'expected')
    other_region = create(:region, name: 'other')
    create(:location, region: region, name: 'in-expected-region-one')
    create(:location, region: region, name: 'in-expected-region-two')
    create(:location, region: other_region, name: 'in-other-region')

    result = Location.in_region('expected')
    assert result.map(&:name).sort == %w[in-expected-region-one in-expected-region-two]
  end
end
