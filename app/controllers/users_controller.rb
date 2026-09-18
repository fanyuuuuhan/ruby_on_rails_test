class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.admin = admin_param if params[:user].key?(:admin)
    if @user.save
      redirect_to login_path, notice: t("users.controller.create_success")
    else
      flash.now[:alert] = t("users.controller.create_fail")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def admin_param
    ActiveModel::Type::Boolean.new.cast(params[:user][:admin])
  end
end
