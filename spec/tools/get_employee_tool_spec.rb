require "rails_helper"

RSpec.describe GetEmployeeTool do
  let!(:department) do
    Department.create!(name: "Engineering")
  end

  let!(:employee) do
    Employee.create!(
      name: "John Doe",
      email: "john@example.com",
      designation: "Software Engineer",
      department: department
    )
  end

  describe ".call" do
    it "returns employee details" do
      result = described_class.call(
        employee_id: employee.id,
        server_context: nil
      )

      data = JSON.parse(result.content.first[:text])

      expect(data["name"]).to eq("John Doe")
      expect(data["email"]).to eq("john@example.com")
      expect(data["department"]).to eq("Engineering")
    end

    it "returns employee not found message" do
      result = described_class.call(
        employee_id: 999999,
        server_context: nil
      )

      expect(result.content.first[:text]).to eq(
        "Employee not found."
      )
    end

    it "requires employee ID or email" do
      result = described_class.call(
        server_context: nil
      )

      expect(result.content.first[:text]).to eq(
        "Provide an Employee ID or Email."
      )
    end
  end
end