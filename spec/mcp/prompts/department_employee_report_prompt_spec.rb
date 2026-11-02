require "rails_helper"

RSpec.describe DepartmentEmployeeReportPrompt do
  describe ".template" do
    let(:department) { "Engineering" }

    subject(:result) do
      described_class.template(
        { "department" => department },
        server_context: nil
      )
    end

    it "returns a prompt result" do
      expect(result).to be_a(MCP::Prompt::Result)
    end

    it "includes the department name in the description" do
      expect(result.description).to eq(
        "Employee report for Engineering"
      )
    end

    it "returns a user message" do
      expect(result.messages.size).to eq(1)
      expect(result.messages.first.role).to eq("user")
    end

    it "returns text content" do
      content = result.messages.first.content

      expect(content).to be_a(MCP::Content::Text)
      expect(content.text).to be_present
    end

    it "includes the department name in the prompt instructions" do
      content = result.messages.first.content.text

      expect(content).to include("Engineering")
    end

    it "instructs the AI to use the search employees tool" do
      content = result.messages.first.content.text

      expect(content).to include("search_employees")
    end

    it "includes the required report sections" do
      content = result.messages.first.content.text

      expect(content).to include("Department name")
      expect(content).to include("Total number of employees")
      expect(content).to include("Employee names")
      expect(content).to include("Employee designations")
      expect(content).to include("Employee email addresses")
    end

    it "instructs the AI not to invent employee details" do
      content = result.messages.first.content.text

      expect(content).to include("Do not invent employee details")
    end

    it "instructs the AI to handle departments with no employees" do
      content = result.messages.first.content.text

      expect(content).to include("If no employees are found")
    end
  end
end