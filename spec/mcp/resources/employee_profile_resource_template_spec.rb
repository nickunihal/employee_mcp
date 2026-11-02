require "rails_helper"

RSpec.describe EmployeeProfileResourceTemplate do
  let!(:department) do
    Department.create!(name: "Engineering")
  end

  let!(:employee) do
    Employee.create!(
      name: "John Doe",
      email: "john@example.com",
      designation: "Software Engineer",
      department: department,
      joined_at: Date.new(2024, 1, 15),
      last_login_at: Time.zone.parse("2026-10-30 10:30:00"),
      active: true
    )
  end

  describe ".contents" do
    subject(:contents) do
      described_class.contents(employee_id: employee.id)
    end

    it "returns resource contents" do
      expect(contents).to all(be_a(MCP::Resource::TextContents))
    end

    it "returns the correct resource URI" do
      expect(contents.first.uri).to eq(
        "employees://#{employee.id}/profile"
      )
    end

    it "returns the correct MIME type" do
      expect(contents.first.mime_type).to eq("application/json")
    end

    it "returns valid JSON" do
      expect {
        JSON.parse(contents.first.text)
      }.not_to raise_error
    end

    it "returns the employee profile with all expected attributes" do
      result = JSON.parse(contents.first.text)

      expect(result).to include(
        "id" => employee.id,
        "name" => "John Doe",
        "email" => "john@example.com",
        "designation" => "Software Engineer",
        "department" => "Engineering",
        "active" => true
      )

      expect(result["joined_at"]).to be_present
      expect(result["last_login_at"]).to be_present
    end

    it "uses GetEmployeeService to retrieve the employee" do
      expect(GetEmployeeService)
        .to receive(:call)
        .with(employee_id: employee.id)
        .and_call_original

      contents
    end

    context "when the employee does not exist" do
      it "raises a ResourceNotFoundError" do
        expect {
          described_class.contents(employee_id: 999_999)
        }.to raise_error(MCP::Server::ResourceNotFoundError)
      end
    end
  end
end