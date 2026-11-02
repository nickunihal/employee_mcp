require "rails_helper"

RSpec.describe EmployeeCountTool do
  let!(:department) do
    Department.create!(name: "Engineering")
  end

  before do
    3.times do |i|
      Employee.create!(
        name: "Engineer #{i}",
        email: "engineer#{i}@example.com",
        designation: "Software Engineer",
        department: department
      )
    end
  end

  describe ".call" do
    it "returns department-wise employee counts" do
      result = described_class.call(
        server_context: nil
      )

      data = JSON.parse(result.content.first[:text])

      expect(data["total"]).to eq(3)

      expect(
        data["departments"]["Engineering"]
      ).to eq(3)
    end

    it "filters employees by department" do
      result = described_class.call(
        department: "Engineering",
        server_context: nil
      )

      data = JSON.parse(result.content.first[:text])

      expect(data["total"]).to eq(3)
      expect(data["departments"].keys).to eq(
        ["Engineering"]
      )
    end

    it "returns zero when department has no employees" do
      result = described_class.call(
        department: "Finance",
        server_context: nil
      )

      data = JSON.parse(result.content.first[:text])

      expect(data["total"]).to eq(0)
      expect(data["departments"]).to eq({})
    end
  end
end