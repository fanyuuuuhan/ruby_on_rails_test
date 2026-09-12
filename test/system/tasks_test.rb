require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  test "建立新增任務" do
    visit tasks_url
    click_on "新增任務"
    fill_in "任務名稱", with: "任務標題"
    fill_in "任務描述", with: "任務內容說明"
    select "待處理", from: "任務狀態"
    click_on "新增任務"
    assert_text "任務建立成功"
  end

  test "編輯任務" do
    task = create(:task)
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
    task = create(:task)
    visit tasks_url
    within("li", text: task.title) do
      accept_confirm do
        click_on "刪除"
      end
    end
    assert_text "任務刪除成功"
    assert_not Task.exists?(task.id)
  end

  test "查看任務" do
    task = create(:task)
    visit task_url(task)
    assert_text task.title
    assert_text task.content
    assert_text task.status
  end
end
