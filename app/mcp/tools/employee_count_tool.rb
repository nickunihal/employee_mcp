
class EmployeeCountTool < MCP::Tool
  description <<~DESC
    Get employee counts grouped by department.
    Optionally filter by department and joining date range.
    Returns total employees, total departments and
    department-wise employee counts.
    Dates must use YYYY-MM-DD format.
  DESC

  input_schema(
    properties: {
      department: {
        type: "string",
        description: "Optional department name to search for"
      },
      joined_after: {
        type: "string",
        description: "Optional inclusive joining date lower bound (YYYY-MM-DD)"
      },
      joined_before: {
        type: "string",
        description: "Optional inclusive joining date upper bound (YYYY-MM-DD)"
      }
    }
  )

  annotations(
    read_only_hint: true,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false
  )

  class << self
    def call(
      department: nil,
      joined_after: nil,
      joined_before: nil,
      server_context:
    )
      result = EmployeeCountService.call(
        department: department,
        joined_after: joined_after,
        joined_before: joined_before
      )

      response(JSON.pretty_generate(result))
    rescue ArgumentError => e
      response("Invalid date filter: #{e.message}")
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
