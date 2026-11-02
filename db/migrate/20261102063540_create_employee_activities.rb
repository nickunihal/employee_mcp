class CreateEmployeeActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :employee_activities do |t|
      t.references :employee, null: false, foreign_key: true
      t.string :activity_type
      t.datetime :occurred_at

      t.timestamps
    end
  end
end
