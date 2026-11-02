class DepartmentEmployeeReportPrompt < MCP::Prompt
  prompt_name "department_employee_report"

  title "Department Employee Report"

  description <<~DESC
    Generate a summary report of employees belonging to a department.
  DESC

  arguments [
    MCP::Prompt::Argument.new(
      name: "department",
      title: "Department",
      description: "Name of the department to generate the report for",
      required: true
    )
  ]

  class << self
    def template(args, server_context:)
      department = args["department"] || args[:department]
      department = department.to_s.strip

      raise ArgumentError, "Department is required" if department.blank?

      MCP::Prompt::Result.new(
        description: "Employee report for #{department}",
        messages: [
          MCP::Prompt::Message.new(
            role: "user",
            content: MCP::Content::Text.new(
              <<~PROMPT
                Generate an employee report for the #{department} department.

                Follow these instructions:

                1. Use the search_employees MCP tool to retrieve employees
                   belonging to the #{department} department.

                2. Review the employee information returned by the tool.

                3. Generate a structured report containing:
                   - Department name
                   - Total number of employees returned
                   - Employee names
                   - Employee designations
                   - Employee email addresses

                4. Provide a brief summary of the department's workforce.

                5. Highlight any useful observations based only on the
                   retrieved information.

                6. Do not invent employee details or assume information
                   that was not returned by the tool.

                7. If no employees are found, clearly mention that.

                Present the report in readable Markdown.
              PROMPT
            )
          )
        ]
      )
    end
  end
end