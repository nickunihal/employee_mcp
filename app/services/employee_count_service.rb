class EmployeeCountService

  attr_reader :department

  def initialize(department: nil)
    @department = department
  end

  def self.call(department: nil)
    new(department: department).call
  end

  def call
    employees = Employee.left_joins(:department)

    if department.present?
      employees = employees.where(
        "departments.name ILIKE ?",
        "%#{department}%"
      )
    end

    counts = employees.group("departments.name").count

    {
      total: counts.values.sum,
      departments: counts
    }
  end


end