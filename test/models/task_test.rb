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
    task = Task.new(
      title: "小組會議報告",
      content: "探討專案進度與問題",
      status: "pending")
    assert task.valid?
  end

  test "任務標題不能為空" do
    task = Task.new(
      title: " ",
      content: "無標題任務",
      status: "pending")
    assert_not task.valid?
    assert_includes task.errors[:title], "不能為空白"
  end

  test "任務標題不能超過100個字" do
    task = Task.new(
      title: "a" * 101,
      content: "標題100字以內",
      status: "pending")
    assert_not task.valid?
    assert task.errors[:title].any?
  end

  test "任務標題不得重複" do
    Task.create!(
      title: "重複任務標題",
      status: "pending")
    task = Task.new(
      title: "重複任務標題",
      status: "pending")

    assert_not task.valid?
    assert_includes task.errors[:title], "此標題已經存在"
  end

  test "任務狀態必須是有效的值" do
    task = Task.new(
      title: "任務標題",
      content: "任務內容",
      status: "invalid_status")
    assert_not task.valid?
    assert_includes task.errors[:status], "不是有效的狀態"
  end

  test "任務狀態不能為空" do
    task = Task.new(
      title: "任務標題",
      content: "任務內容",
      status: " ")
    assert_not task.valid?
    assert_includes task.errors[:status], "不能為空白"
  end

  test "任務狀態預設為 pending" do
    task = Task.new(
      title: "任務標題",
      content: "任務內容")
    assert_equal "pending", task.status
  end

  test "任務內容不得超過1000個字" do
    task = Task.new(
      title: "任務標題",
      content: "a" * 1001,
      status: "pending")
    assert_not task.valid?
    assert_includes task.errors[:content], "不能超過1000個字"
  end

  test "任務內容可以為空" do
    task = Task.new(
      title: "任務標題",
      content: nil,
      status: "pending")
    assert task.valid?
  end
end
