class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path, notice: t("users.controller.create_success")
    else
      flash.now[:alert] = t("users.controller.create_fail")
      render :new, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
