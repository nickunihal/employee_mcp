class SearchEmployeeService
  attr_reader :name, :email, :department

  def initialize(name: nil, email: nil, department: nil)
    @name       = name
    @email      = email
    @department = department
  end

  def call
    scope = Employee.includes(:department)

    scope = filter_by_name(scope)
    scope = filter_by_email(scope)
    scope = filter_by_department(scope)

    scope
  end

  def self.call(name: nil, email: nil, department: nil)
    new(name: name, email: email, department: department).call
  end

  private

  def filter_by_name(scope)
    return scope if name.blank?

    scope.where("employees.name ILIKE ?", "%#{sanitize_sql_like(name)}%")
  end

  def filter_by_email(scope)
    return scope if email.blank?

    scope.where("employees.email ILIKE ?", "%#{sanitize_sql_like(email)}%")
  end

  def filter_by_department(scope)
    return scope if department.blank?

    scope.joins(:department)
         .where("departments.name ILIKE ?", "%#{sanitize_sql_like(department)}%")
  end

  def sanitize_sql_like(string)
    ActiveRecord::Base.sanitize_sql_like(string)
  end
end