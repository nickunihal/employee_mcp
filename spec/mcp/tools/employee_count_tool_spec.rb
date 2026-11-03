
require "rails_helper"

RSpec.describe EmployeeCountTool do
  let!(:department) do
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
        department: department
      )
    end
  end

  describe ".call" do
    context "without filters" do
      it "returns total employees and department-wise counts" do
        result = described_class.call(server_context: nil)

        data = JSON.parse(result.content.first[:text])

        expect(data["total_employees"]).to eq(3)
        expect(data["total_departments"]).to eq(1)
        expect(data["departments"]).to eq(
          "Engineering" => 3
        )
      end

      it "passes nil filters to the count service" do
        expect(EmployeeCountService).to receive(:call).with(
          department: nil,
          joined_after: nil,
          joined_before: nil
        ).and_call_original

        described_class.call(server_context: nil)
      end
    end

    context "with department filter" do
      it "filters employees by department" do
        result = described_class.call(
          department: "Engineering",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["total_employees"]).to eq(3)
        expect(data["total_departments"]).to eq(1)
        expect(data["departments"]).to eq(
          "Engineering" => 3
        )
      end
    end

    context "when department has no employees" do
      it "returns zero employees" do
        result = described_class.call(
          department: "Finance",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["total_employees"]).to eq(0)
        expect(data["total_departments"]).to eq(0)
        expect(data["departments"]).to eq({})
      end
    end

    context "with joined_after filter" do
      before do
        Employee.create!(
          name: "Recent Engineer",
          email: "recent-engineer@example.com",
          designation: "Software Engineer",
          department: department,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )
      end

      it "passes joined_after to the count service" do
        expect(EmployeeCountService).to receive(:call).with(
          department: nil,
          joined_after: "2026-10-01",
          joined_before: nil
        ).and_call_original

        described_class.call(
          joined_after: "2026-10-01",
          server_context: nil
        )
      end

      it "counts employees who joined on or after the given date" do
        result = described_class.call(
          joined_after: "2026-10-01",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["total_employees"]).to eq(1)
        expect(data["departments"]).to eq(
          "Engineering" => 1
        )
      end
    end

    context "with joined_before filter" do
      before do
        Employee.create!(
          name: "Older HR Employee",
          email: "older-hr@example.com",
          designation: "HR Executive",
          department: hr,
          joined_at: Time.zone.parse("2026-09-15 10:00:00")
        )
      end

      it "passes joined_before to the count service" do
        expect(EmployeeCountService).to receive(:call).with(
          department: nil,
          joined_after: nil,
          joined_before: "2026-09-30"
        ).and_call_original

        described_class.call(
          joined_before: "2026-09-30",
          server_context: nil
        )
      end

      it "counts employees who joined on or before the given date" do
        result = described_class.call(
          joined_before: "2026-09-30",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["total_employees"]).to eq(1)
        expect(data["departments"]).to eq(
          "Human Resources" => 1
        )
      end
    end

    context "with a date range" do
      before do
        Employee.create!(
          name: "October Engineer",
          email: "october-engineer@example.com",
          designation: "Software Engineer",
          department: department,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )

        Employee.create!(
          name: "September HR Employee",
          email: "september-hr@example.com",
          designation: "HR Executive",
          department: hr,
          joined_at: Time.zone.parse("2026-09-15 10:00:00")
        )

        Employee.create!(
          name: "November HR Employee",
          email: "november-hr@example.com",
          designation: "HR Executive",
          department: hr,
          joined_at: Time.zone.parse("2026-11-15 10:00:00")
        )
      end

      it "passes both date filters to the count service" do
        expect(EmployeeCountService).to receive(:call).with(
          department: nil,
          joined_after: "2026-10-01",
          joined_before: "2026-10-31"
        ).and_call_original

        described_class.call(
          joined_after: "2026-10-01",
          joined_before: "2026-10-31",
          server_context: nil
        )
      end

      it "counts only employees within the date range" do
        result = described_class.call(
          joined_after: "2026-10-01",
          joined_before: "2026-10-31",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["total_employees"]).to eq(1)
        expect(data["total_departments"]).to eq(1)
        expect(data["departments"]).to eq(
          "Engineering" => 1
        )
      end
    end

    context "with department and date filters" do
      before do
        Employee.create!(
          name: "October Engineer",
          email: "october-engineer@example.com",
          designation: "Software Engineer",
          department: department,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )

        Employee.create!(
          name: "October HR Employee",
          email: "october-hr@example.com",
          designation: "HR Executive",
          department: hr,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )
      end

      it "passes department and date filters to the count service" do
        expect(EmployeeCountService).to receive(:call).with(
          department: "Engineering",
          joined_after: "2026-10-01",
          joined_before: "2026-10-31"
        ).and_call_original

        described_class.call(
          department: "Engineering",
          joined_after: "2026-10-01",
          joined_before: "2026-10-31",
          server_context: nil
        )
      end

      it "applies all filters together" do
        result = described_class.call(
          department: "Engineering",
          joined_after: "2026-10-01",
          joined_before: "2026-10-31",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["total_employees"]).to eq(1)
        expect(data["total_departments"]).to eq(1)
        expect(data["departments"]).to eq(
          "Engineering" => 1
        )
      end
    end

    context "when invalid date filters are provided" do
      it "returns an error message for an invalid date" do
        result = described_class.call(
          joined_after: "not-a-date",
          server_context: nil
        )

        expect(result.content.first[:text]).to include(
          "Invalid date filter:"
        )
      end

      it "returns an error message when the date range is reversed" do
        result = described_class.call(
          joined_after: "2026-11-01",
          joined_before: "2026-10-01",
          server_context: nil
        )

        expect(result.content.first[:text]).to include(
          "joined_after cannot be later than joined_before"
        )
      end
    end
  end
end
