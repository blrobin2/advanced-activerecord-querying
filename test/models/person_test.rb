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

  test 'alphabetically_by_region_and_location' do
    region2 = create(:region, name: 'region2')
    region3 = create(:region, name: 'region3')
    region1 = create(:region, name: 'region1')
    location1 = create(:location, name: 'location1', region: region2)
    location4 = create(:location, name: 'location4', region: region1)
    location3 = create(:location, name: 'location3', region: region1)
    location5 = create(:location, name: 'location5', region: region3)
    location2 = create(:location, name: 'location2', region: region1)
    create(:person, name: 'person1', location: location5)
    create(:person, name: 'person5', location: location2)
    create(:person, name: 'person4', location: location4)
    create(:person, name: 'person3', location: location1)
    create(:person, name: 'person2', location: location1)
    create(:person, name: 'person7', location: location1)
    create(:person, name: 'person6', location: location3)

    result = Person.alphabetically_by_region_and_location
    assert result.map(&:name) == %w[
      person5
      person6
      person4
      person2
      person3
      person7
      person1
    ]
  end
end
