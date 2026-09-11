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
  scope :created_at_desc, -> { order(created_at: :desc) }
  scope :created_at_asc,  -> { order(created_at: :asc) }
  scope :title_desc,      -> { order(title: :desc) }
  scope :due_date_desc,   -> { order(due_date: :desc) }
  scope :due_date_asc,    -> { order(due_date: :asc) }
  def self.sorted_by(sort_order)
    sort_order = sort_order.presence || "created_at_desc"
    allowed_scopes={
      "created_at_desc" => :created_at_desc,
      "created_at_asc" => :created_at_asc,
      "title_desc" => :title_desc,
      "due_date_desc" => :due_date_desc,
      "due_date_asc" => :due_date_asc
    }
    scope_name = allowed_scopes.fetch(sort_order, :created_at_desc)
    public_send(scope_name)
  end
  
            
  validate :due_date_cannot_be_in_the_past
  private
  def due_date_cannot_be_in_the_past
    return if due_date.blank?
    errors.add(:due_date, "不能是過去的日期") if due_date < Date.today
  end
end
