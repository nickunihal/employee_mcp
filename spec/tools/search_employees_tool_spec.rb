
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
      it "returns a validation message" do
        result = described_class.call(
          server_context: nil
        )

        expect(result.content.first[:text]).to eq(
          "Provide at least one search filter."
        )
      end

      it "does not invoke the search service" do
        expect(SearchEmployeeService).not_to receive(:call)

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
        expect(SearchEmployeeService).to receive(:call)
          .with(
            name: nil,
            email: nil,
            department: "Engineering"
          )
          .and_call_original

        described_class.call(
          department: "Engineering",
          server_context: nil
        )
      end
    end

    context "when multiple filters are provided" do
      it "passes all filters to the search service" do
        expect(SearchEmployeeService).to receive(:call)
          .with(
            name: "John",
            email: "john@example.com",
            department: "Engineering"
          )
          .and_call_original

        described_class.call(
          name: "John",
          email: "john@example.com",
          department: "Engineering",
          server_context: nil
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
