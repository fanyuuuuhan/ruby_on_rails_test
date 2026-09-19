require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, password: "password123", password_confirmation: "password123")
    visit login_url
    fill_in "email", with: @user.email
    fill_in "password", with: "password123"
    find('input[type="submit"]').click

    assert_current_path tasks_path
  end

  test "建立新增任務" do
    visit tasks_url
    visit new_task_path
    fill_in "任務名稱", with: "任務標題"
    fill_in "任務描述", with: "任務內容說明"
    select "待處理", from: "任務狀態"
    page.execute_script("document.querySelector('form').submit();")
    assert_current_path tasks_path, wait: 5
    assert_text "任務建立成功"
  end

  test "編輯任務" do
    task = create(:task)
    task = create(:task, user: @user)
    visit tasks_url
    within("turbo-frame##{dom_id(task)}") do
      click_on "編輯"
      fill_in "任務名稱", with: "更新後的任務標題"
      fill_in "任務描述", with: "更新後的任務內容說明"
      select "進行中", from: "任務狀態"
      click_on "更新任務"
    end

    assert_text "任務更新成功"
  end

  test "刪除任務" do
    task = create(:task, user: @user)
    visit tasks_url
    within("li", text: task.title) do
      accept_confirm(wait: 5) do
        click_on "刪除"
      end
    end
    assert_text "任務刪除成功"
    assert_not Task.exists?(task.id)
  end

  test "查看任務" do
    task = create(:task)
    task = create(:task, user: @user)
    visit task_url(task)
    assert_text task.title
    assert_text task.content
    assert_text task.status
  end

  test "依任務名稱查詢" do
    matching_task = create(
      :task,
      user: @user,
      title: "任務標題A",
      status: "pending"
    )
    create(
      :task,
      user: @user,
      title: "任務標題B",
      status: "pending"
    )
    visit tasks_url
    fill_in "搜尋任務名稱", with: "A"
    click_on "查詢"
    assert_text matching_task.title
    assert_no_text "任務標題B"
  end

  test "依任務狀態查詢" do
    matching_task = create(
      :task,
      user: @user,
      title: "待處理任務",
      status: "pending"
    )
    create(
      :task,
      user: @user,
      title: "已完成任務",
      status: "completed"
    )
    visit tasks_url
    select "待處理", from: "任務狀態"
    click_on "查詢"
    assert_text matching_task.title
    assert_no_text "已完成任務"
  end

  test "依截止日期查詢" do
    matching_due_date = Date.current + 1.day
    outside_due_date = Date.current + 8.days

    matching_task = create(
      :task,
      user: @user,
      title: "時間內任務",
      status: "pending",
      due_date: matching_due_date
    )
    create(
      :task,
      user: @user,
      title: "時間外任務",
      status: "pending",
      due_date: outside_due_date
    )
    visit tasks_path(
      due_date_gteq: Date.current,
      due_date_lteq: Date.current + 2.days
    )
    assert_text matching_task.title
    assert_no_text "時間外任務"
  end
end
