class Location < ApplicationRecord
  belongs_to :region
  has_many :people

  scope :in_region, ->(region) { joins(:region).merge(Region.in_region(region)) }
  scope :billable, -> { joins(:people).merge(Person.billable).distinct }
  scope :by_region_and_location_name, lambda {
    joins(:region).merge(Region.order(:name)).order(:name)
  }

  scope :billable_by_region_and_location_name, lambda {
    from(billable, :locations).by_region_and_location_name
  }
end
