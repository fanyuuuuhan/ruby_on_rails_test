class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false # 標題
      t.text :content # 內文
      t.string :status, default: "pending", null: false # 狀態

      # 時間戳記
      t.timestamps
    end
  end
end
