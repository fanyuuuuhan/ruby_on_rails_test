require "test_helper"

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
class TaskTest < ActiveSupport::TestCase
  test "有效的task可建立" do
    task = build(
      :task,
      title: "小組會議報告",
      content: "探討專案進度與問題",
      status: "pending")
    assert task.valid?
  end

  test "任務標題不能為空" do
    task = build(
      :task,
      title: " ",
      content: "無標題任務",
      status: "pending")
    assert_not task.valid?
    assert_includes task.errors[:title], "不能為空白"
  end

  test "任務標題不能超過100個字" do
    task = build(
      :task,
      title: "a" * 101,
      content: "標題100字以內",
      status: "pending")
    assert_not task.valid?
    assert task.errors[:title].any?
  end

  test "任務標題不得重複" do
    create(
      :task,
      title: "重複任務標題",
      status: "pending")
    task = build(
      :task,
      title: "重複任務標題",
      status: "pending")

    assert_not task.valid?
    assert_includes task.errors[:title], "此標題已經存在"
  end

  test "任務狀態必須是有效的值" do
    task = build(
      :task,
      title: "任務標題",
      content: "任務內容",
      status: "invalid_status")
    assert_not task.valid?
    assert_includes task.errors[:status], "不是有效的狀態"
  end

  test "任務狀態不能為空" do
    task = build(
      :task,
      title: "任務標題",
      content: "任務內容",
      status: " ")
    assert_not task.valid?
    assert_includes task.errors[:status], "不能為空白"
  end

  test "任務狀態預設為 pending" do
    task = build(
      :task,
      title: "任務標題",
      content: "任務內容")
    assert_equal "pending", task.status
  end

  test "任務優先順序使用 enum 且預設為 low" do
    task = build(
      :task,
      title: "任務標題",
      status: "pending")

    assert_equal "low", task.priority
    assert_equal "low", Task.priorities[:low]
    assert task.low?
  end

  test "任務優先順序只能是有效的 enum 值" do
    task = build(
      :task,
      title: "任務標題",
      status: "pending",
      priority: "invalid")

    assert_not task.valid?
    assert task.errors[:priority].any?
  end

  test "任務內容不得超過1000個字" do
    task = build(
      :task,
      title: "任務標題",
      content: "a" * 1001,
      status: "pending")
    assert_not task.valid?
    assert_includes task.errors[:content], "不能超過1000個字"
  end

  test "任務內容可以為空" do
    task = build(
      :task,
      title: "任務標題",
      content: nil,
      status: "pending")
    assert task.valid?
  end

  test "可以使用字串排序參數" do
    older_task = create(
      :task,
      title: "較早任務",
      status: "pending",
      created_at: 2.days.ago)
    newer_task = create(
      :task,
      title: "較新任務",
      status: "pending",
      created_at: 1.day.ago)

    result = Task
      .where(id: [ older_task.id, newer_task.id ])
      .sorted_by("created_at_asc")

    assert_equal [ older_task, newer_task ], result.to_a
  end

  test "可以依優先順序排序且忽略未列入白名單的排序參數" do
    low_task = create(
      :task,
      title: "低優先",
      status: "pending",
      priority: "low")
    high_task = create(
      :task,
      title: "高優先",
      status: "pending",
      priority: "high")
    scoped_tasks = Task.where(id: [ low_task.id, high_task.id ])

    assert_equal [ high_task, low_task ], scoped_tasks.sorted_by("priority_desc").to_a
    assert_equal Task.sorted_by(:created_at_desc).to_sql,
                 Task.sorted_by("priority; DROP TABLE tasks").to_sql
  end

  test "可以精準查詢標題名稱" do
    matching_task = create(
      :task,
      title: "專案報告",
      status: "pending")
    create(
      :task,
      title: "其他任務",
      status: "pending")

    result = Task.title_eq("專案報告")

    assert_equal [ matching_task ], result.to_a
  end

  test "可以模糊查詢標題名稱" do
    matching_task = create(
      :task,
      title: "專案報告",
      status: "pending")
    create(
      :task,
      title: "專案紀錄",
      status: "pending")

    result = Task.title_cont("報告")

    assert_equal [ matching_task ], result.to_a
  end

  test "可以查詢狀態" do
    pending_task = create(
      :task,
      title: "待辦任務",
      status: "pending")
    create(
      :task,
      title: "進行中任務",
      status: "in_progress")

    result = Task.status_eq("pending")

    assert_includes result.to_a, pending_task
    assert_not result.exists?(title: "進行中任務")
  end

  test "可以查詢多個狀態" do
    pending_task = create(
      :task,
      title: "待辦任務",
      status: "pending")
    in_progress_task = create(
      :task,
      title: "進行中任務",
      status: "in_progress")
    create(
      :task,
      title: "已完成任務",
      status: "completed")

    result = Task.status_in([ "pending", "in_progress" ])

    assert_includes result.to_a, pending_task
    assert_includes result.to_a, in_progress_task
    assert_not result.exists?(title: "已完成任務")
  end

  test "可以查詢單一和多個優先順序" do
    low_task = create(
      :task,
      title: "低優先任務",
      status: "pending",
      priority: "low")
    high_task = create(
      :task,
      title: "高優先任務",
      status: "pending",
      priority: "high")
    medium_task = create(
      :task,
      title: "中優先任務",
      status: "pending",
      priority: "medium")
    scoped_tasks = Task.where(id: [ low_task.id, high_task.id, medium_task.id ])

    assert_equal [ high_task ], Task.priority_eq("high").to_a
    assert_equal [ low_task, high_task ], scoped_tasks.priority_in(%w[low high]).to_a
    assert_empty Task.priority_in([ "invalid" ]).to_a
  end

  test "可以查詢指定截止日期起始之後的任務" do
    create(
      :task,
      title: "早期任務",
      status: "pending",
      due_date: Date.current
    )
    matching_task = create(
      :task,
      title: "符合任務",
      status: "pending",
      due_date: Date.current + 3.days
    )

    result = Task.due_date_gteq(Date.current + 2.days)

    assert_equal [ matching_task ], result.to_a
  end

    test "可以查詢指定截止日期之前的任務" do
    create(
      :task,
      title: "晚期任務",
      status: "pending",
      due_date: Date.current + 7.days
    )
    matching_task = create(
      :task,
      title: "符合任務",
      status: "pending",
      due_date: Date.current + 2.days
    )

    result = Task.due_date_lteq(Date.current + 2.days)

    assert_equal [ matching_task ], result.to_a
  end

  test "可以查詢到指定截止日期範圍內的任務" do
    before_range = create(
      :task,
      title: "截止日期前的任務",
      status: "pending",
      due_date: Date.today
    )
    in_range = create(
      :task,
      title: "範圍內任務",
      status: "pending",
      due_date: Date.today + 2.days
    )
    after_range = create(
      :task,
      title: "截止日期後的任務",
      status: "pending",
      due_date: Date.today + 7.days
    )
    result = Task.due_date_gteq(Date.today + 1.day).due_date_lteq(Date.today + 6.days)

    assert_equal [ in_range ], result.to_a
    assert_not_includes result.to_a, before_range
    assert_not_includes result.to_a, after_range
  end

  test "可以串接多個 scope" do
    matching_task = create(
      :task,
      title: "專案報告待處理",
      status: "pending",
      due_date: Date.current + 2.days
    )

    create(
      :task,
      title: "專案報告已完成",
      status: "completed",
      due_date: Date.current + 2.days
    )

    result = Task
      .title_cont("報告")
      .status_eq("pending")
      .due_date_gteq(Date.current)
      .due_date_lteq(Date.current + 7.days)

    assert_equal [ matching_task ], result.to_a
  end

  test "空值不套用篩選" do
    first_task = create(
      :task,
      title: "任務一",
      status: "pending",
    )
    second_task = create(
      :task,
      title: "任務二",
      status: "in_progress",
    )

    result = Task
      .title_eq("")
      .title_cont(nil)
      .status_eq("")
      .status_in([])
      .due_date_gteq(nil)
      .due_date_lteq("")

    assert_equal Task.all.to_a, result.to_a
  end
end
