class SearchEmployeesTool < MCP::Tool
  description <<~DESC
    Search employees by name, email or department.
    Returns employee details including name, email,
    designation and department.
  DESC

  input_schema(
    properties: {
      name: {
        type: "string",
        description: "Employee name to search for"
      },
      email: {
        type: "string",
        description: "Employee email to search for"
      },
      department: {
        type: "string",
        description: "Department name to filter by"
      },
      limit: {
        type: "integer",
        description: "Maximum number of results (1-50)",
        minimum: 1,
        maximum: 50
      }
    }
  )

  class << self
    def call(name: nil, email: nil, department: nil, limit: 20, server_context: )
      if [name, email, department].all?(&:blank?)
        return response("Provide at least one search filter.")
      end

      limit = [[limit.to_i, 1].max, 50].min

      employees = SearchEmployeeService.call(name: name,email: email,department: department)

      results = employees.limit(limit).map do |employee|
        {
          id: employee.id,
          name: employee.name,
          email: employee.email,
          designation: employee.designation,
          department: employee.department.name
        }
      end

      response(
        JSON.pretty_generate(
          count: results.size,
          employees: results
        )
      )
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