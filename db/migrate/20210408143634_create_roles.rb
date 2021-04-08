class CreateRoles < ActiveRecord::Migration[6.1]
  def change
    create_table :roles do |t|
      t.string :name
      t.boolean :billable
      t.timestamps
    end
  end
end
