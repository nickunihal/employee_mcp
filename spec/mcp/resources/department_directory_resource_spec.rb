require "rails_helper"

RSpec.describe DepartmentDirectoryResource do
  let!(:engineering) { Department.create!(name: "Engineering") }
  let!(:hr) { Department.create!(name: "Human Resources") }
  let!(:operations) { Department.create!(name: "Operations") }

  let!(:john) do
    Employee.create!(
      name: "John Doe",
      email: "john@example.com",
      designation: "Software Engineer",
      department: engineering
    )
  end

  let!(:jane) do
    Employee.create!(
      name: "Jane Smith",
      email: "jane@example.com",
      designation: "Senior Engineer",
      department: engineering
    )
  end

  let!(:mike) do
    Employee.create!(
      name: "Mike Johnson",
      email: "mike@example.com",
      designation: "HR Executive",
      department: hr
    )
  end

  describe ".contents" do
    subject(:contents) { described_class.contents }

    it "returns resource contents" do
      expect(contents).to all(be_a(MCP::Resource::TextContents))
    end

    it "returns the correct resource URI" do
      expect(contents.first.uri).to eq("employees://departments")
    end

    it "returns JSON content" do
      expect(contents.first.mime_type).to eq("application/json")
      expect { JSON.parse(contents.first.text) }.not_to raise_error
    end

    it "returns all departments with their employee counts" do
      result = JSON.parse(contents.first.text)

      expect(result).to contain_exactly(
        {
          "id" => engineering.id,
          "name" => "Engineering",
          "employee_count" => 2
        },
        {
          "id" => hr.id,
          "name" => "Human Resources",
          "employee_count" => 1
        },
        {
          "id" => operations.id,
          "name" => "Operations",
          "employee_count" => 0
        }
      )
    end
  end
end