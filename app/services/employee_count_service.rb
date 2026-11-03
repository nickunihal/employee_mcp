class EmployeeCountService

  attr_reader :department, :joined_after, :joined_before

  def initialize(department: nil, joined_after: nil, joined_before: nil)
    @department = department
    @joined_after = parse_date(joined_after)
    @joined_before  = parse_date(joined_before)

    if @joined_after && @joined_before && @joined_after > @joined_before
      raise ArgumentError, "joined_after cannot be later than joined_before"
    end
  end

  def self.call(department: nil, joined_after: nil, joined_before: nil)
    new(department: department, joined_after: joined_after, joined_before: joined_before).call
  end

  def call
    employees = Employee.left_joins(:department)

    if department.present?
      employees = employees.where(
        "departments.name ILIKE ?",
        "%#{ActiveRecord::Base.sanitize_sql_like(department)}%"
      )
    end

    if joined_after
      employees = employees.where("employees.joined_at >= ?", joined_after.beginning_of_day)
    end

    if joined_before
      employees = employees.where("employees.joined_at <= ?", joined_before.end_of_day)
    end

    counts = employees.group("departments.name").count

    {
      total_employees: counts.values.sum,
      total_departments: counts.keys.compact.count,
      departments: counts
    }
  end

  private

  def parse_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue Date::Error
    raise ArgumentError, "dates must use DD-MM-YYYY or YYYY-MM-DD format"
  end

end