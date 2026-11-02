# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
departments = [
  "Engineering",
  "Human Resources",
  "Finance",
  "Marketing",
  "Sales"
]

employee_designation_mapping = {
  "Engineering" => "Software Engineer",
  "Human Resources" => "HR",
  "Finance" => "Accountant",
  "Marketing" => "Social Media Associate",
  "Sales" => "Sales Executive"
}

departments.each do |name|
  department = Department.find_or_create_by!(name: name)

  20.times do |i|
    Employee.find_or_create_by!(
      email: "#{name.downcase.gsub(' ', '')}#{i + 1}@example.com"
    ) do |employee|
      employee.name = "#{name} Employee #{i + 1}"
      employee.designation = employee_designation_mapping[department]
      employee.department = department
      employee.joined_at = rand(1..1000).days.ago
      employee.last_login_at = rand(1..90).days.ago
      employee.active = true
    end
  end
	end

puts "Created #{Employee.count} employees"