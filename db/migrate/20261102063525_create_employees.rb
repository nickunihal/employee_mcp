class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :name
      t.string :email
      t.string :designation
      t.references :department, null: false, foreign_key: true
      t.datetime :joined_at
      t.datetime :last_login_at
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :employees, :email, unique: true
  end
end
