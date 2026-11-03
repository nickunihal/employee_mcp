
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
    context "without department or date filters" do
      it "returns total employees and department-wise counts" do
        result = described_class.call

        expect(result[:total_employees]).to eq(5)
        expect(result[:total_departments]).to eq(2)

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
        result = described_class.call(department: "Engineering")

        expect(result[:total_employees]).to eq(3)
        expect(result[:total_departments]).to eq(1)
        expect(result[:departments]).to eq(
          "Engineering" => 3
        )
      end
    end

    context "when department does not exist" do
      it "returns zero employees" do
        result = described_class.call(department: "Operations")

        expect(result[:total_employees]).to eq(0)
        expect(result[:total_departments]).to eq(0)
        expect(result[:departments]).to eq({})
      end
    end

    context "with joined_after filter" do
      before do
        Employee.create!(
          name: "Recent Engineer",
          email: "recent-engineer@example.com",
          department: engineering,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )
      end

      it "counts employees who joined on or after the given date" do
        result = described_class.call(joined_after: "2026-10-15")

        expect(result[:total_employees]).to eq(1)
        expect(result[:total_departments]).to eq(1)
        expect(result[:departments]).to eq(
          "Engineering" => 1
        )
      end
    end

    context "with joined_before filter" do
      before do
        Employee.create!(
          name: "Older HR Employee",
          email: "older-hr@example.com",
          department: hr,
          joined_at: Time.zone.parse("2026-09-15 10:00:00")
        )
      end

      it "counts employees who joined on or before the given date" do
        result = described_class.call(joined_before: "2026-09-15")

        expect(result[:total_employees]).to eq(1)
        expect(result[:total_departments]).to eq(1)
        expect(result[:departments]).to eq(
          "Human Resources" => 1
        )
      end
    end

    context "with a date range" do
      before do
        Employee.create!(
          name: "October Engineer",
          email: "october-engineer@example.com",
          department: engineering,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )

        Employee.create!(
          name: "September HR Employee",
          email: "september-hr@example.com",
          department: hr,
          joined_at: Time.zone.parse("2026-09-15 10:00:00")
        )

        Employee.create!(
          name: "November HR Employee",
          email: "november-hr@example.com",
          department: hr,
          joined_at: Time.zone.parse("2026-11-15 10:00:00")
        )
      end

      it "counts only employees within the date range" do
        result = described_class.call(
          joined_after: "2026-10-01",
          joined_before: "2026-10-31"
        )

        expect(result[:total_employees]).to eq(1)
        expect(result[:total_departments]).to eq(1)
        expect(result[:departments]).to eq(
          "Engineering" => 1
        )
      end
    end

    context "with department and date filters" do
      before do
        Employee.create!(
          name: "October Engineer",
          email: "october-engineer@example.com",
          department: engineering,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )

        Employee.create!(
          name: "October HR Employee",
          email: "october-hr@example.com",
          department: hr,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )
      end

      it "applies both filters together" do
        result = described_class.call(
          department: "Engineering",
          joined_after: "2026-10-01",
          joined_before: "2026-10-31"
        )

        expect(result[:total_employees]).to eq(1)
        expect(result[:total_departments]).to eq(1)
        expect(result[:departments]).to eq(
          "Engineering" => 1
        )
      end
    end

    context "when invalid date filters are provided" do
      it "raises an ArgumentError when joined_after is later than joined_before" do
        expect {
          described_class.call(
            joined_after: "2026-11-01",
            joined_before: "2026-10-01"
          )
        }.to raise_error(
          ArgumentError,
          "joined_after cannot be later than joined_before"
        )
      end
    end
  end
end
