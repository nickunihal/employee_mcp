class GetEmployeeTool < MCP::Tool
  description <<~DESC
    Fetch employee by employee id or email.
    Returns all employee details including name, email,
    designation, department and joining date.
  DESC

  input_schema(
    properties: {
      employee_id: {
        type: "integer",
        description: "Employee database id to search for"
      },
      email: {
        type: "string",
        description: "Employee email to search for"
      }
    }
  )

  class << self
    def call(employee_id: nil, email: nil, server_context: )
      if [employee_id, email].all?(&:blank?)
        return response("Provide an Employee ID or Email.")
      end

      employee = GetEmployeeService.call(employee_id: employee_id,email: email)

      return response("Employee not found.") unless employee

      result = {
          id: employee.id,
          name: employee.name,
          email: employee.email,
          designation: employee.designation,
          department: employee.department.name,
          joined_at: employee.joined_at
        }

      response(JSON.pretty_generate(result))
    end

    private

    def response(message)
      MCP::Tool::Response.new([
        {
        type: "text",
        text: message
        }
      ])
    end
  end
end