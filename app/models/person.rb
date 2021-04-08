class Person < ApplicationRecord
  belongs_to :location
  belongs_to :role
  belongs_to :manager, class_name: 'Person', foreign_key: :manager_id, optional: true
  has_many :employees, class_name: 'Person', foreign_key: :manager_id

  scope :billable, -> { joins(:role).merge(Role.billable) }
  scope :in_region, ->(region) { joins(:location).merge(Location.in_region(region)) }
  scope :with_employees, -> { joins(:employees).distinct }

  scope :with_managers, -> { left_joins(:manager) }
  scope :not_managed, -> { with_managers.where(manager: { id: nil }) }
  scope :not_managed_by, lambda { |name|
    with_managers.where.not(manager: { id: find_by!(name: name) }).or(not_managed)
  }

  scope :alphabetically_by_region_and_location, lambda {
    joins(location: :region).order('regions.name, locations.name, people.name')
  }
  scope :order_by_location_name, -> { joins(:location).merge(Location.order(:name)) }

  scope :with_employees_order_by_location_name, lambda {
    from(with_employees, :people).order_by_location_name
  }
end
