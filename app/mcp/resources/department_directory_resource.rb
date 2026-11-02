class DepartmentDirectoryResource < MCP::Resource
  uri "employees://departments"
  resource_name "department-directory"
  title "Department Directory"
  description "Lists all departments and their employee counts."
  mime_type "application/json"

  class << self
    def contents
      departments = Department
        .left_joins(:employees)
        .group("departments.id", "departments.name")
        .count("employees.id")

      data = departments.map do |(department_id, department_name), employee_count|
        {
          id: department_id,
          name: department_name,
          employee_count: employee_count
        }
      end

      [
        MCP::Resource::TextContents.new(
          uri: uri,
          mime_type: mime_type,
          text: data.to_json
        )
      ]
    end
  end
end