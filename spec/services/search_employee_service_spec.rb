require "rails_helper"

RSpec.describe SearchEmployeeService do
  let!(:engineering) { Department.create!(name: "Engineering") }
  let!(:hr) { Department.create!(name: "Human Resources") }

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

  describe ".call" do
    context "when no filters are provided" do
      it "returns all employees" do
        result = described_class.call

        expect(result).to contain_exactly(john, jane, mike)
      end
    end

    context "when filtering by name" do
      it "returns matching employees" do
        result = described_class.call(name: "John Doe")

        expect(result).to contain_exactly(john)
      end

      it "performs case-insensitive matching" do
        result = described_class.call(name: "john doe")

        expect(result).to contain_exactly(john)
      end

      it "supports partial name matching" do
        result = described_class.call(name: "Jan")

        expect(result).to contain_exactly(jane)
      end

      it "matches partial names contained within other names" do
        result = described_class.call(name: "John")

        expect(result).to contain_exactly(john, mike)
      end
    end

    context "when filtering by email" do
      it "returns matching employees" do
        result = described_class.call(email: "john@example.com")

        expect(result).to contain_exactly(john)
      end

      it "performs case-insensitive matching" do
        result = described_class.call(email: "JOHN@EXAMPLE.COM")

        expect(result).to contain_exactly(john)
      end

      it "supports partial email matching" do
        result = described_class.call(email: "example.com")

        expect(result).to contain_exactly(john, jane, mike)
      end
    end

    context "when filtering by department" do
      it "returns employees belonging to the department" do
        result = described_class.call(department: "Engineering")

        expect(result).to contain_exactly(john, jane)
      end

      it "performs case-insensitive matching" do
        result = described_class.call(department: "engineering")

        expect(result).to contain_exactly(john, jane)
      end

      it "supports partial department matching" do
        result = described_class.call(department: "Human")

        expect(result).to contain_exactly(mike)
      end
    end

    context "when multiple filters are provided" do
      it "applies all filters together" do
        result = described_class.call(
          name: "John Doe",
          email: "john@example.com",
          department: "Engineering"
        )

        expect(result).to contain_exactly(john)
      end

      it "returns no results when filters do not match the same employee" do
        result = described_class.call(
          name: "Doe",
          department: "Human Resources"
        )

        expect(result).to be_empty
      end
    end

    context "when special SQL wildcard characters are provided" do
      it "treats percentage signs as literal characters" do
        result = described_class.call(name: "%")

        expect(result).to be_empty
      end

      it "treats underscores as literal characters" do
        result = described_class.call(name: "_")

        expect(result).to be_empty
      end
    end

    context "when no employees match" do
      it "returns an empty ActiveRecord relation" do
        result = described_class.call(name: "Nonexistent")

        expect(result).to be_a(ActiveRecord::Relation)
        expect(result).to be_empty
      end
    end

    context "when blank filters are provided" do
      it "ignores blank filters" do
        result = described_class.call(
          name: "",
          email: "",
          department: ""
        )

        expect(result).to contain_exactly(john, jane, mike)
      end
    end

        context "when filtering by joined_after" do
      let!(:recent_employee) do
        Employee.create!(
          name: "Recent Employee",
          email: "recent@example.com",
          department: engineering,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )
      end

      it "returns employees who joined on or after the given date" do
        result = described_class.call(joined_after: "2026-10-15")

        expect(result).to include(recent_employee)
        expect(result).not_to include(john, jane, mike)
      end
    end

    context "when filtering by joined_before" do
      let!(:older_employee) do
        Employee.create!(
          name: "Older Employee",
          email: "older@example.com",
          department: engineering,
          joined_at: Time.zone.parse("2026-09-15 10:00:00")
        )
      end

      it "returns employees who joined on or before the given date" do
        result = described_class.call(joined_before: "2026-09-15")

        expect(result).to include(older_employee)
        expect(result).not_to include(john, jane, mike)
      end
    end

    context "when filtering by a date range" do
      let!(:employee_in_range) do
        Employee.create!(
          name: "Employee In Range",
          email: "inrange@example.com",
          department: engineering,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )
      end

      let!(:employee_before_range) do
        Employee.create!(
          name: "Employee Before Range",
          email: "before@example.com",
          department: hr,
          joined_at: Time.zone.parse("2026-09-15 10:00:00")
        )
      end

      let!(:employee_after_range) do
        Employee.create!(
          name: "Employee After Range",
          email: "after@example.com",
          department: hr,
          joined_at: Time.zone.parse("2026-11-15 10:00:00")
        )
      end

      it "returns only employees who joined within the date range" do
        result = described_class.call(
          joined_after: "2026-10-01",
          joined_before: "2026-10-31"
        )

        expect(result).to contain_exactly(employee_in_range)
      end

      it "includes employees who joined on the boundary dates" do
        start_employee = Employee.create!(
          name: "Start Date Employee",
          email: "start@example.com",
          department: engineering,
          joined_at: Time.zone.parse("2026-10-01 00:00:00")
        )

        end_employee = Employee.create!(
          name: "End Date Employee",
          email: "end@example.com",
          department: engineering,
          joined_at: Time.zone.parse("2026-10-31 23:59:59")
        )

        result = described_class.call(
          joined_after: "2026-10-01",
          joined_before: "2026-10-31"
        )

        expect(result).to contain_exactly(
          employee_in_range,
          start_employee,
          end_employee
        )
      end
    end

    context "when combining department and date filters" do
      let!(:engineering_employee) do
        Employee.create!(
          name: "Engineering New Joiner",
          email: "engineering-new@example.com",
          department: engineering,
          joined_at: Time.zone.parse("2026-10-15 10:00:00")
        )
      end

      let!(:hr_employee) do
        Employee.create!(
          name: "HR New Joiner",
          email: "hr-new@example.com",
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

        expect(result).to contain_exactly(engineering_employee)
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

  describe "initialization" do
    it "stores the supplied filters" do
      service = described_class.new(
        name: "John",
        email: "john@example.com",
        department: "Engineering"
      )

      expect(service.name).to eq("John")
      expect(service.email).to eq("john@example.com")
      expect(service.department).to eq("Engineering")
    end

    it "stores the supplied date filters" do
      service = described_class.new(
        joined_after: "2026-10-01",
        joined_before: "2026-10-31"
      )

      expect(service.joined_after).to eq(Date.new(2026, 10, 1))
      expect(service.joined_before).to eq(Date.new(2026, 10, 31))
    end
  end
end