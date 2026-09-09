class TasksController < ApplicationController
  # 在顯示、編輯、更新和刪除操作之前，先設定好 @task
  # 避免重複的程式碼
  before_action :set_task, only: %i[show edit update destroy]


  def index
    @tasks = Task.all
  end

  def show
  end

  # 顯示新增任務的表單
  def new
    @task = Task.new
  end

  # 建立任務
  # 失敗回到new
  def create
    @task = Task.new(task_params)
    if @task.save
      redirect_to tasks_path, notice: "任務建立成功"
    else
      flash.now[:alert] = "任務建立失敗"
      render :new, status: :unprocessable_entity
    end
  end

  # 更新任務
  # 成功->詳細頁面，
  # 失敗->回到編輯頁面
  def update
    if @task.update(task_params)
      redirect_to @task, notice: "任務更新成功"
    else
      flash.now[:alert] = "任務更新失敗"
      render :edit, status: :unprocessable_entity
    end
  end

  # 刪除任務
  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "任務刪除成功"
  end

  # 編輯任務
  def edit
  end

  private
  # 僅允許 title, content, status 這三個欄位被傳入
  def task_params
    params.require(:task).permit(:title, :content, :status)
  end

  def set_task
    @task = Task.find(params[:id])
  end
end
