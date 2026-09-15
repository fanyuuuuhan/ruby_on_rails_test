class AddPriorityToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :priority, :string, default: "low", null: false
    add_index :tasks, :priority
  end
end
