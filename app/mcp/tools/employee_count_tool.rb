class EmployeeCountTool < MCP::Tool
  description <<~DESC
    Get employee counts grouped by department.
    Optionally filter by department name.
    Returns total employees and department-wise counts.
  DESC

  input_schema(
    properties: {
      department: {
        type: "string",
        description: "Optional department name to search for"
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
    def call(department: nil, server_context: )

      result = EmployeeCountService.call(department: department)

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