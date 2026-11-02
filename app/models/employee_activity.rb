class EmployeeActivity < ApplicationRecord
  belongs_to :employee

  validates :activity_type, presence: true
end
