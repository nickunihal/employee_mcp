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
  end
end