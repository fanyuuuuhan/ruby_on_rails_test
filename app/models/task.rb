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
  SORT_ORDERS = {
    title_asc: { title: :asc },
    created_at_desc: { created_at: :desc },
    created_at_asc: { created_at: :asc },
    due_date_desc: { due_date: :desc },
    due_date_asc: { due_date: :asc }
  }.freeze
  scope :sorted_by, ->(sort_order = created_at_desc) do
   select_order = sort_order&.to_sym || :created_at_desc
   order(SORT_ORDERS.fetch(select_order, SORT_ORDERS[:created_at_desc]))
  end
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
  validates_comparison_of :due_date,
            greater_than_or_equal_to: -> { Date.current },
            allow_blank: true
end
