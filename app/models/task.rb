# == Schema Information
#
# Table name: tasks
#
#  id         :bigint           not null, primary key
#  content    :text
#  status     :string           default("pending"), not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Task < ApplicationRecord
  validates :title, presence: true,
            length: { maximum: 100 },
            uniqueness: {
              case_sensitive: false,
              message: "此標題已經存在"
            }
  validates :content,
            length: {
              maximum: 1000,
              message: "不能超過1000個字"
            },
            allow_blank: true
  validates :status, presence: true,
            inclusion: {
              in: %w[pending in_progress completed],
              message: "不是有效的狀態"
            }
end
