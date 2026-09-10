class AddTaskConstraints < ActiveRecord::Migration[8.1]
  def change
    add_index :tasks,
      "LOWER(TRIM(title))",
      unique: true,
      name: "unique_task_title"

    add_check_constraint :tasks,
      "char_length((content)) <= 1000",
      name: "task_content_length_check"

    add_check_constraint :tasks,
      "status IN ('pending', 'in_progress', 'completed')",
      name: "task_status_check"
  end
end
