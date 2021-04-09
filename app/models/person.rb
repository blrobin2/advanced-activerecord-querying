class Person < ApplicationRecord
  belongs_to :location
  belongs_to :role
  belongs_to :manager, class_name: 'Person', foreign_key: :manager_id, optional: true
  has_many :employees, class_name: 'Person', foreign_key: :manager_id

  scope :billable, -> { joins(:role).merge(Role.billable) }
  scope :non_billable, -> { joins(:role).where(roles: { billable: false }) }
  scope :in_region, ->(region) { joins(:location).merge(Location.in_region(region)) }
  scope :with_employees, lambda {
    from(
      joins(:employees).distinct,
      :people
    )
  }

  scope :with_managers, -> { left_joins(:manager) }
  scope :not_managed, -> { with_managers.where(manager: { id: nil }) }
  scope :not_managed_by, lambda { |name|
    with_managers.where.not(manager: { id: find_by!(name: name) }).or(not_managed)
  }

  scope :without_remote_manager, lambda {
    with_managers.where(manager: { id: nil }).or(where('people.location_id = manager.location_id'))
  }

  scope :with_local_coworkers, lambda {
    from(
      joins(location: :people)
        .where('people_locations.id <> people.id')
        .distinct,
      :people
    )
  }

  scope :alphabetically_by_region_and_location, lambda {
    joins(location: :region).order('regions.name, locations.name, people.name')
  }
  scope :order_by_location_name, -> { joins(:location).merge(Location.order(:name)) }

  scope :with_employees_order_by_location_name, lambda {
    with_employees.order_by_location_name
  }

  scope :non_billable_salary, -> { non_billable.sum(:salary) }
  scope :employees_per_person, -> { left_joins(:employees).group('people.name').count('employees_people.id') }

  scope :lower_than_average_salaries, lambda {
    salary_per_location_sql = select('location_id', 'AVG(salary) AS average')
                              .group('location_id')
                              .to_sql

    joins("INNER JOIN (#{salary_per_location_sql}) salaries ON salaries.location_id = people.location_id")
      .where('people.salary < salaries.average')
  }

  scope :highest_salaried_people_ordered_by_name, lambda {
    salary_rank_sql = select('id', 'rank() OVER (ORDER BY salary DESC)').to_sql

    joins("INNER JOIN (#{salary_rank_sql}) salaries ON salaries.id = people.id")
      .where('salaries.rank <= 3')
      .order(:name)
  }

  scope :maximum_salary_by_location, lambda {
    group(:location_id).maximum(:salary)
  }

  scope :managers_by_average_salary_difference, lambda {
    avg_salary_per_employee = select('manager_id', 'AVG(salary) AS average')
                              .group('manager_id')
                              .to_sql

    joins(
      "INNER JOIN (#{avg_salary_per_employee}) salaries ON salaries.manager_id = people.id " +
      'ORDER BY (people.salary - salaries.average) DESC'
    )

    # I prefer this way, even though it's an extra sub-query...
    # salary_diff_per_manager = joins("INNER JOIN (#{avg_salary_per_employee}) salaries ON salaries.manager_id = people.id")
    #                           .select('people.id', '(people.salary - salaries.average) AS difference')
    #                           .group('people.id', 'salaries.average')
    #                           .to_sql

    # joins("INNER JOIN (#{salary_diff_per_manager}) manager_salaries ON manager_salaries.id = people.id")
    #   .order('manager_salaries.difference DESC')
  }
end
