class GetEmployeeService

  attr_reader :employee_id, :email

  def initialize(employee_id: nil,email: nil)
    @employee_id = employee_id
    @email      = email
  end

  def self.call(employee_id: nil,email: nil)
    new(employee_id: employee_id, email: email).call
  end

  def call
    employee = Employee.includes(:department)

    employee =
      if employee_id.present?
        employee.find_by(id: employee_id)
      elsif email.present?
        employee.find_by(email: email)
      end

    employee    
  end


end