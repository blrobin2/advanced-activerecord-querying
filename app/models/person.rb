class Person < ApplicationRecord
  belongs_to :role

  # scope :billable, -> { joins(:role).where(role: { billable: true }) }
  scope :billable, -> { joins(:role).merge(Role.billable) }
end
