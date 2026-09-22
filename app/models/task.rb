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
  belongs_to :user
  has_many :task_tags, dependent: :destroy
  has_many :tags, through: :task_tags

  enum :status, {
    pending: "pending",
    in_progress: "in_progress",
    completed: "completed"
  }, validate: true

  SORT_ORDERS = %i[
    title_asc
    created_at_desc
    created_at_asc
    due_date_desc
    due_date_asc
    priority_asc
    priority_desc
  ].to_h do |sort_order|
    column, direction = sort_order.to_s.split(/_(?=[^_]+$)/)
    [ sort_order, { column => direction.to_sym } ]
  end.merge(
    priority_asc: Arel.sql(
      "CASE priority WHEN 'low' THEN 0 WHEN 'medium' THEN 1 WHEN 'high' THEN 2 ELSE 3 END ASC"
    ),
    priority_desc: Arel.sql(
      "CASE priority WHEN 'high' THEN 0 WHEN 'medium' THEN 1 WHEN 'low' THEN 2 ELSE 3 END ASC"
    )
  ).freeze
  scope :sorted_by, ->(sort_order = :created_at_desc) do
    sort_order = sort_order.to_s.to_sym
    order(SORT_ORDERS[sort_order] || SORT_ORDERS[:created_at_desc])
  end

  SEARCH_SCOPES = %w[
    title_eq
    title_cont
    status_eq
    status_in
    due_date_gteq
    due_date_lteq
    priority_eq
    priority_in
    tag_names
  ].freeze

  enum :priority, {
    low: "low",
    medium: "medium",
    high: "high"
  }, validate: true
  def self.search(filters = {})
    relation = all
    filters.each do |key, value|
      next unless SEARCH_SCOPES.include?(key.to_s)

      scope_name = key.to_s == "tag_names" ? :by_tag_names : key
      relation = relation.public_send(scope_name, value)
    end
    relation
  end

  scope :title_eq, ->(value) {
    value.present? ? where(title: value) : all
  }
  scope :title_cont, ->(value) {
    if value.present?
      value_escaped = sanitize_sql_like(value.to_s)
      where("title LIKE ?", "%#{value_escaped}%")
    else
      all
    end
  }
  scope :status_eq, ->(value) {
    value.present? ? where(status: value) : all
  }
  scope :status_in, ->(values) {
    values = Array(values).reject(&:blank?)
    values.present? ? where(status: values) : all
  }
  scope :due_date_gteq, ->(value) {
    value.present? ? where("due_date >= ?", value.to_date) : all
  }
  scope :due_date_lteq, ->(value) {
    value.present? ? where("due_date <= ?", value.to_date) : all
  }
  scope :priority_eq, ->(value) {
    value.present? ? where(priority: priorities[value.to_s]) : all
  }
  scope :priority_in, ->(values) {
    values = Array(values).reject(&:blank?)
    next all if values.empty?

    valid_priorities = values.filter do |value|
      self.priorities.key?(value.to_s)
    end.map do |value|
      self.priorities[value.to_s]
    end

    valid_priorities.present? ? where(priority: valid_priorities) : none
  }
  scope :by_tag_names, ->(input) {
    names = input.to_s.split("，").map(&:strip).compact_blank
    if names.present?
      tasks = Task.arel_table
      tags = Tag.arel_table
      task_tags = TaskTag.arel_table

      task_condition = task_tags[:task_id].eq(tasks[:id])
      tag_condition = tags[:name].in(names)
      combined_condition = task_condition.and(tag_condition)
      tags_exists =
        TaskTag
          .joins(:tag)
          .where(combined_condition)
          .arel
          .exists
      where(tags_exists)
    else
      all
    end
  }
  def tag_names
    tags.pluck(:name).join("，")
  end

  def tag_names=(names)
    self.tags = names.to_s.split("，").map do |name|
      Tag.find_or_create_by(name: name.strip)
    end
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
