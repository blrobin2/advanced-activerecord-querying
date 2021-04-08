require "test_helper"

class PersonTest < ActiveSupport::TestCase
  test 'in_region' do
    region = create(:region, name: 'expected')
    other_region = create(:region, name: 'other')
    in_region = create(:location, region: region)
    in_other_region = create(:location, region: other_region)
    create(:person, location: in_region, name: 'in-expected-region-one')
    create(:person, location: in_region, name: 'in-expected-region-two')
    create(:person, location: in_other_region, name: 'in-other-region')

    result = Person.in_region('expected')
    assert result.map(&:name).sort == %w[in-expected-region-one in-expected-region-two]
  end
end
