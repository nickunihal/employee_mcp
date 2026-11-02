class Employee < ApplicationRecord

  belongs_to :department
  has_many :employee_activities, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

end
