class SearchEmployeesTool < MCP::Tool
  description <<~DESC
    Search or list employees by name, email, department or joining date.
    All filters are optional.
    If no filters are provided, returns employees ordered by ID.
    Dates must use YYYY-MM-DD format.
    Returns employee details including name, email, designation,
    department and joining date.
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
      joined_after: {
        type: "string",
        description: "Inclusive joining date lower bound (YYYY-MM-DD)"
      },
      joined_before: {
        type: "string",
        description: "Inclusive joining date upper bound (YYYY-MM-DD)"
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
    def call(name: nil, email: nil, department: nil, joined_after: nil, joined_before: nil, limit: 20, server_context: )
      limit = [[limit.to_i, 1].max, 50].min

      employees = SearchEmployeeService.call(name: name,email: email,department: department,joined_after: joined_after,joined_before: joined_before)

      results = employees.order(:id).limit(limit).map do |employee|
        {
          id: employee.id,
          name: employee.name,
          email: employee.email,
          designation: employee.designation,
          department: employee.department.name,
          joined_at: employee.joined_at
        }
      end

      response(
        JSON.pretty_generate(
          count: results.size,
          employees: results
        )
      )
    rescue ArgumentError => e
      response("Invalid search filter: #{e.message}")
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