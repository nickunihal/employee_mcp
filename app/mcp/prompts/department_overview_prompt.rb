class DepartmentOverviewPrompt < MCP::Prompt
  prompt_name "department_overview"

  title "Department Overview"

  description <<~DESC
    Generate a department overview using employee search
    and employee count information.
  DESC

  arguments [
    MCP::Prompt::Argument.new(
      name: "department",
      title: "Department",
      description: "Department to generate the overview for",
      required: true
    )
  ]

  class << self
    def template(args, server_context:)
      department = args["department"] || args[:department]
      department = department.to_s.strip

      raise ArgumentError, "Department is required" if department.blank?

      MCP::Prompt::Result.new(
        description: "Department overview for #{department}",
        messages: [
          MCP::Prompt::Message.new(
            role: "user",
            content: MCP::Content::Text.new(
              <<~PROMPT
                Generate a comprehensive overview for the
                #{department} department.

                You have access to the following MCP tools:

                1. search_employees
                   Use this tool to retrieve employees belonging
                   to the #{department} department.

                2. employee_count
                   Use this tool to retrieve the employee count
                   for the #{department} department.

                Follow these steps:

                1. Call search_employees with the department name.
                2. Call employee_count with the department name.
                3. Compare the employee count with the number
                   of employees returned by the search.
                4. Generate a structured department overview.

                Include these sections:

                - Department name
                - Total employee count
                - Employee directory
                - Employee names and designations
                - Workforce summary
                - Observations

                Important instructions:

                - Use actual results returned by the tools.
                - Do not invent employee information.
                - If the tools return different counts, mention
                  the discrepancy instead of assuming they match.
                - If no employees are found, clearly state that.
                - Present the final report in readable Markdown.
              PROMPT
            )
          )
        ]
      )
    end
  end
end