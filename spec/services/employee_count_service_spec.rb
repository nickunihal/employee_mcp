require "rails_helper"

RSpec.describe EmployeeCountService do
  let!(:engineering) do
    Department.create!(name: "Engineering")
  end

  let!(:hr) do
    Department.create!(name: "Human Resources")
  end

  before do
    3.times do |i|
      Employee.create!(
        name: "Engineer #{i}",
        email: "engineer#{i}@example.com",
        designation: "Software Engineer",
        department: engineering
      )
    end

    2.times do |i|
      Employee.create!(
        name: "HR Employee #{i}",
        email: "hr#{i}@example.com",
        designation: "HR Executive",
        department: hr
      )
    end
  end

  describe ".call" do
    context "without department filter" do
      it "returns total employees and department-wise counts" do
        result = described_class.call

        expect(result[:total]).to eq(5)

        expect(result[:departments]).to eq(
          {
            "Engineering" => 3,
            "Human Resources" => 2
          }
        )
      end
    end

    context "with department filter" do
      it "returns employees belonging to the requested department" do
        result = described_class.call(
          department: "Engineering"
        )

        expect(result[:total]).to eq(3)

        expect(result[:departments]).to eq(
          {
            "Engineering" => 3
          }
        )
      end
    end

    context "when department does not exist" do
      it "returns zero employees" do
        result = described_class.call(
          department: "Operations"
        )

        expect(result[:total]).to eq(0)
        expect(result[:departments]).to eq({})
      end
    end
  end
end