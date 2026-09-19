class Admin::UsersController < ApplicationController
  before_action :require_login
  before_action :require_admin
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.includes(:tasks).all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @tasks = @user.tasks.order(created_at: :desc)
  end

  def edit
  end

  def update
    @user = User.find(params[:id])
    @user.admin = params[:user][:admin] if params[:user].key?(:admin)
    if @user.update(user_params)
      redirect_to admin_user_path(@user)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: t(".cannot_delete_self")
      return
    end

    if @user.destroy
      redirect_to admin_users_path, notice: t(".deleted_success")
    else
      redirect_to admin_users_path, alert: @user.errors.full_messages.to_sentence
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation,
    )
  end
end
