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

  test 'order_by_location_name' do
    locations = [
      create(:location, name: 'location1'),
      create(:location, name: 'location3'),
      create(:location, name: 'location2')
    ]
    locations.each do |location|
      create(:person, location: location, name: "at-#{location.name}")
    end

    result = Person.order_by_location_name
    assert result.map(&:name) == %w[at-location1 at-location2 at-location3]
  end

  test 'with_employees' do
    managers = [
      create(:person, name: 'manager-one'),
      create(:person, name: 'manager-two')
    ]
    managers.each do |manager|
      2.times do
        create(:person, name: "employee-of-#{manager.name}", manager: manager)
      end
    end

    result = Person.with_employees
    assert result.map(&:name).sort == %w[manager-one manager-two]
  end

  test 'with_employees_order_by_location_name' do
    locations = [
      create(:location, name: 'location1'),
      create(:location, name: 'location3'),
      create(:location, name: 'location2')
    ]
    managers = locations.map do |location|
      create(:person, name: "manager-at-#{location.name}", location: location)
    end
    managers.each do |manager|
      2.times do
        create(:person, name: "employee-of-#{manager.name}", manager: manager)
      end
    end

    result = Person.with_employees_order_by_location_name
    assert result.map(&:name) == %w[
      manager-at-location1
      manager-at-location2
      manager-at-location3
    ]
  end

  test 'without_remote_manager' do
    local = create(:location)
    remote = create(:location)
    local_manager = create(
      :person,
      location: local,
      name: 'local_manager',
      manager: nil
    )
    remote_manager = create(
      :person,
      location: remote,
      name: 'remote_manager',
      manager: nil
    )
    create(
      :person,
      location: local,
      manager: local_manager,
      name: 'has_local_manager'
    )
    create(
      :person,
      location: local,
      manager: remote_manager,
      name: 'has_remote_manager'
    )

    result = Person.without_remote_manager
    assert result.map(&:name).sort == %w[has_local_manager local_manager remote_manager]
  end

  test 'with_local_coworkers' do
    location = create(:location)
    other_location = create(:location)
    create(:person, location: location, name: 'with-coworkers-one')
    create(:person, location: location, name: 'with-coworkers-two')
    create(:person, location: location, name: 'with-coworkers-three')
    create(:person, location: other_location, name: 'without-coworkers')

    result = Person.with_local_coworkers
    assert result.map(&:name).sort == %w[
      with-coworkers-one
      with-coworkers-three
      with-coworkers-two
    ]
  end

  test 'with_employees.with_local_coworkers.order_by_location_name' do
    locations = [
      create(:location, name: 'location1'),
      create(:location, name: 'location3'),
      create(:location, name: 'location2')
    ]
    managers = locations.map do |location|
      create(:person, name: "coworker-#{location.name}", location: location)
      create(:person, name: "manager-#{location.name}", location: location)
    end
    managers.each do |manager|
      2.times do
        create(:person, name: "employee-#{manager.name}", manager: manager)
      end
    end

    result = Person.with_employees.with_local_coworkers.order_by_location_name
    assert result.map(&:name) == %w[
      manager-location1
      manager-location2
      manager-location3
    ]
  end

  def find_names(hash_by_id)
    hash_by_id.inject({}) do |hash_by_name, (id, value)|
      name = Location.find(id).name
      hash_by_name.merge(name => value)
    end
  end

  test 'maximum_salary_by_location' do
    [50_000, 60_000].each do |highest_salary|
      location = create(:location, name: "highest-#{highest_salary}")
      create(:person, location: location, salary: highest_salary - 1)
      create(:person, location: location, salary: highest_salary)
    end

    result = Person.maximum_salary_by_location

    assert find_names(result) == {
      'highest-50000' => 50_000,
      'highest-60000' => 60_000
    }
  end

  test 'managers_by_average_salary_difference' do
    highest_difference = [45_000, 20_000]
    medium_difference = [50_000, 10_000]
    lowest_difference = [50_000, -5_000]
    ordered_differences = [highest_difference, medium_difference, lowest_difference]

    ordered_differences.each do |(salary, difference)|
      manager = create(:person, salary: salary, name: "difference-#{difference}")
      create(:person, manager: manager, salary: salary - difference * 1)
      create(:person, manager: manager, salary: salary - difference * 2)
      create(:person, manager: manager, salary: salary - difference * 3)
    end

    result = Person.managers_by_average_salary_difference

    assert result.map(&:name) == %w[
      difference-20000
      difference-10000
      difference--5000
    ]
  end
end
