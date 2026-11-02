class EmployeeProfileResourceTemplate < MCP::ResourceTemplate
  uri_template "employees://{employee_id}/profile"

  resource_template_name "employee-profile"

  title "Employee Profile"

  description "Returns detailed information about an employee."

  mime_type "application/json"

  class << self
    def contents(employee_id:)
      employee = GetEmployeeService.call(employee_id: employee_id)

      resource_uri = "employees://#{employee_id}/profile"

      unless employee
        raise MCP::Server::ResourceNotFoundError.new(
          resource_uri,
          { uri: resource_uri }
        )
      end

      data = {
        id: employee.id,
        name: employee.name,
        email: employee.email,
        designation: employee.designation,
        department: employee.department&.name,
        joined_at: employee.joined_at,
        last_login_at: employee.last_login_at,
        active: employee.active
      }

      [
        MCP::Resource::TextContents.new(
          uri: resource_uri,
          mime_type: mime_type,
          text: data.to_json
        )
      ]
    end
  end
end