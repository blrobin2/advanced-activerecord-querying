class Person < ApplicationRecord
  belongs_to :location
  belongs_to :role
  belongs_to :manager, class_name: 'Person', foreign_key: :manager_id
  has_many :employees, class_name: 'Person', foreign_key: :manager_id

  scope :billable, -> { joins(:role).merge(Role.billable) }
  scope :in_region, ->(region) { joins(:location).merge(Location.in_region(region)) }

  scope :alphabetically_by_region_and_location, -> { all }
end
