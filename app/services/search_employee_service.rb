class SearchEmployeeService
  attr_reader :name, :email, :department, :joined_after, :joined_before

  def initialize(name: nil, email: nil, department: nil, joined_after: nil, joined_before: nil)
    @name = name
    @email = email
    @department = department
    @joined_after = parse_date(joined_after)
    @joined_before = parse_date(joined_before)

    validate_date_range
  end

  def call
    scope = Employee.includes(:department)

    scope = filter_by_name(scope)
    scope = filter_by_email(scope)
    scope = filter_by_department(scope)
    scope = filter_by_joined_after(scope)
    scope = filter_by_joined_before(scope)

    scope
  end

  def self.call(**args)
    new(**args).call
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

  def filter_by_joined_after(scope)
    return scope if joined_after.blank?

    scope.where("employees.joined_at >= ?", joined_after.beginning_of_day)    
  end

  def filter_by_joined_before(scope)
    return scope if joined_before.blank?

    scope.where("employees.joined_at <= ?", joined_before.end_of_day)    
  end

  def sanitize_sql_like(string)
    ActiveRecord::Base.sanitize_sql_like(string)
  end

  def validate_date_range
    return unless joined_after && joined_before
    return unless joined_after > joined_before

    raise ArgumentError, "joined_after cannot be later than joined_before"    
  end

  def parse_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue Date::Error
    raise ArgumentError, "dates must use DD-MM-YYYY or YYYY-MM-DD format"
  end
end