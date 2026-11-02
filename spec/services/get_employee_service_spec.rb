require "rails_helper"

RSpec.describe GetEmployeeService do
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
    context "when employee ID is provided" do
      it "returns the matching employee" do
        result = described_class.call(
          employee_id: employee.id
        )

        expect(result).to eq(employee)
      end
    end

    context "when email is provided" do
      it "returns the matching employee" do
        result = described_class.call(
          email: employee.email
        )

        expect(result).to eq(employee)
      end
    end

    context "when employee does not exist" do
      it "returns nil" do
        result = described_class.call(
          employee_id: 999999
        )

        expect(result).to be_nil
      end
    end
  end
end