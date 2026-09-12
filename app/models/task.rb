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
  SORT_ORDERS = %i[
    title_asc
    created_at_desc
    created_at_asc
    due_date_desc
    due_date_asc
].to_h do |sort_order|
  column, direction = sort_order.to_s.split(/_(?=[^_]+$)/)
  [ sort_order, { column => direction.to_sym } ]
end.freeze
  scope :sorted_by, ->(sort_order = :created_at_desc) do
   sort_key = sort_order&.to_sym || :created_at_desc
   order(SORT_ORDERS[sort_key] || SORT_ORDERS[:created_at_desc])
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
