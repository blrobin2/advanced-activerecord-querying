class CreatePeople < ActiveRecord::Migration[6.1]
  def change
    create_table :people do |t|
      t.string :name, null: false
      t.references :role, null: false, foreign_key: true
      t.integer :location_id
      t.integer :manager_id
      t.integer :salary, null: false

      t.timestamps
    end
  end
end
