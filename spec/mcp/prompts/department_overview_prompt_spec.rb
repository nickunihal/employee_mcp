require "rails_helper"

RSpec.describe DepartmentOverviewPrompt do
  describe ".template" do
    let(:department) { "Engineering" }

    subject(:result) do
      described_class.template(
        { "department" => department },
        server_context: nil
      )
    end

    let(:prompt_text) do
      result.messages.first.content.text.squish
    end

    it "returns a prompt result" do
      expect(result).to be_a(MCP::Prompt::Result)
    end

    it "includes the department in the description" do
      expect(result.description).to eq(
        "Department overview for Engineering"
      )
    end

    it "includes the department name in the instructions" do
      expect(prompt_text).to include("Engineering")
    end

    it "instructs the AI to use the employee search tool" do
      expect(prompt_text).to include("search_employees")
    end

    it "instructs the AI to use the employee count tool" do
      expect(prompt_text).to include("employee_count")
    end

    it "instructs the AI to compare employee counts" do
      expect(prompt_text).to include(
        "Compare the employee count"
      )
    end

    it "instructs the AI not to invent employee information" do
      expect(prompt_text).to include(
        "Do not invent employee information"
      )
    end

    it "instructs the AI to handle discrepancies" do
      expect(prompt_text).to include(
        "mention the discrepancy"
      )
    end
  end
end