class Location < ApplicationRecord
  belongs_to :region
  has_many :people

  scope :in_region, ->(region) { joins(:region).merge(Region.in_region(region)) }
end
