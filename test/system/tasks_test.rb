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
    task_title = "任務標題#{SecureRandom.hex(4)}"
    visit tasks_url
    visit new_task_path
    within("form") do
      fill_in "task_title", with: task_title
      fill_in "task_content", with: "任務內容說明"
      select "待處理", from: "task_status"
      select "低", from: "task_priority"
      click_button "新增任務"
    end
    assert_current_path tasks_path, wait: 10
    assert_text task_title
  end

  test "編輯任務" do
    task = create(:task, user: @user)
    updated_title = "更新後的任務標題#{SecureRandom.hex(4)}"
    visit edit_task_path(task)
    within("turbo-frame##{dom_id(task)}") do
      fill_in "task_title", with: updated_title
      fill_in "task_content", with: "更新後的任務內容說明"
      select "進行中", from: "task_status"
      click_button "更新任務"
    end

    assert_text updated_title
    assert_current_path tasks_path, wait: 10
  end

  test "刪除任務" do
    task = create(:task, user: @user)
    visit tasks_url
    within("li", text: task.title) do
      delete_button = find("button", text: "刪除")
      accept_confirm do
        delete_button.click
      end
    end
    assert_no_text task.title, wait: 5
    assert_current_path tasks_path
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
    visit tasks_url(title_cont: "A")
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
