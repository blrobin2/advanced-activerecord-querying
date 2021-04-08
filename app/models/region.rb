class Region < ApplicationRecord
  has_many :locations

  scope :in_region, ->(region) { where(name: region) }
end
