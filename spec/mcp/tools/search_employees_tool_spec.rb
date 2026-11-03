
require "rails_helper"

RSpec.describe SearchEmployeesTool do
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
    context "when no search filters are provided" do
      it "returns employees without requiring a search filter" do
        result = described_class.call(server_context: nil)

        data = JSON.parse(result.content.first[:text])

        expect(data["count"]).to eq(1)
        expect(data["employees"].first["name"]).to eq("John Doe")
      end

      it "invokes the search service without filters" do
        expect(SearchEmployeeService).to receive(:call).with(
          name: nil,
          email: nil,
          department: nil,
          joined_after: nil,
          joined_before: nil
        ).and_call_original

        described_class.call(server_context: nil)
      end
    end

    context "when searching by name" do
      it "returns matching employees" do
        result = described_class.call(
          name: "John",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["count"]).to eq(1)
        expect(data["employees"].first).to include(
          "id" => employee.id,
          "name" => "John Doe",
          "email" => "john@example.com",
          "designation" => "Software Engineer",
          "department" => "Engineering"
        )
      end
    end

    context "when searching by department" do
      it "passes department to the search service" do
        expect(SearchEmployeeService).to receive(:call).with(
          name: nil,
          email: nil,
          department: "Engineering",
          joined_after: nil,
          joined_before: nil
        ).and_call_original

        described_class.call(
          department: "Engineering",
          server_context: nil
        )
      end
    end

    context "when multiple filters are provided" do
      it "passes all filters to the search service" do
        expect(SearchEmployeeService).to receive(:call).with(
          name: "John",
          email: "john@example.com",
          department: "Engineering",
          joined_after: nil,
          joined_before: nil
        ).and_call_original

        described_class.call(
          name: "John",
          email: "john@example.com",
          department: "Engineering",
          server_context: nil
        )
      end
    end

    context "when filtering by joined_after" do
      let!(:recent_employee) do
        Employee.create!(
          name: "Recent Employee",
          email: "recent@example.com",
          designation: "Software Engineer",
          department: department,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )
      end

      it "passes joined_after to the search service" do
        expect(SearchEmployeeService).to receive(:call).with(
          name: nil,
          email: nil,
          department: nil,
          joined_after: "2026-10-01",
          joined_before: nil
        ).and_call_original

        described_class.call(
          joined_after: "2026-10-01",
          server_context: nil
        )
      end

      it "returns employees who joined on or after the given date" do
        result = described_class.call(
          joined_after: "2026-10-01",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["employees"].map { |item| item["id"] })
          .to contain_exactly(recent_employee.id)
      end
    end

    context "when filtering by joined_before" do
      let!(:older_employee) do
        Employee.create!(
          name: "Older Employee",
          email: "older@example.com",
          designation: "Software Engineer",
          department: department,
          joined_at: Time.zone.parse("2026-09-15 10:00:00")
        )
      end

      it "passes joined_before to the search service" do
        expect(SearchEmployeeService).to receive(:call).with(
          name: nil,
          email: nil,
          department: nil,
          joined_after: nil,
          joined_before: "2026-09-30"
        ).and_call_original

        described_class.call(
          joined_before: "2026-09-30",
          server_context: nil
        )
      end

      it "returns employees who joined on or before the given date" do
        result = described_class.call(
          joined_before: "2026-09-30",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["employees"].map { |item| item["id"] })
          .to contain_exactly(older_employee.id)
      end
    end

    context "when filtering by a date range" do
      let!(:employee_in_range) do
        Employee.create!(
          name: "October Employee",
          email: "october@example.com",
          designation: "Software Engineer",
          department: department,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )
      end

      it "passes both date filters to the search service" do
        expect(SearchEmployeeService).to receive(:call).with(
          name: nil,
          email: nil,
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

      it "returns employees within the date range" do
        result = described_class.call(
          joined_after: "2026-10-01",
          joined_before: "2026-10-31",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["employees"].map { |item| item["id"] })
          .to contain_exactly(employee_in_range.id)
      end
    end

    context "when combining department and date filters" do
      let!(:recent_employee) do
        Employee.create!(
          name: "Recent Engineer",
          email: "recent-engineer@example.com",
          designation: "Software Engineer",
          department: department,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )
      end

      it "passes department and date filters to the service" do
        expect(SearchEmployeeService).to receive(:call).with(
          name: nil,
          email: nil,
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

      it "returns employees matching both filters" do
        result = described_class.call(
          department: "Engineering",
          joined_after: "2026-10-01",
          joined_before: "2026-10-31",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["employees"].map { |item| item["id"] })
          .to contain_exactly(recent_employee.id)
      end
    end

    context "when invalid date filters are provided" do
      it "returns an error message for an invalid date" do
        result = described_class.call(
          joined_after: "not-a-date",
          server_context: nil
        )

        expect(result.content.first[:text]).to include("Invalid search filter:")
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

    context "when no employees match" do
      it "returns an empty employee list" do
        result = described_class.call(
          name: "Unknown",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["count"]).to eq(0)
        expect(data["employees"]).to eq([])
      end
    end

    context "when limit is provided" do
      before do
        5.times do |i|
          Employee.create!(
            name: "Employee #{i}",
            email: "employee#{i}@example.com",
            designation: "Engineer",
            department: department
          )
        end
      end

      it "limits the returned employees" do
        result = described_class.call(
          department: "Engineering",
          limit: 2,
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["count"]).to eq(2)
        expect(data["employees"].size).to eq(2)
      end

      it "uses 20 as the default limit" do
        result = described_class.call(
          department: "Engineering",
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["count"]).to eq(6)
      end

      it "does not allow a limit greater than 50" do
        result = described_class.call(
          department: "Engineering",
          limit: 100,
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["count"]).to eq(6)
      end

      it "does not allow a limit below 1" do
        result = described_class.call(
          department: "Engineering",
          limit: 0,
          server_context: nil
        )

        data = JSON.parse(result.content.first[:text])

        expect(data["count"]).to eq(1)
      end
    end
  end
end
