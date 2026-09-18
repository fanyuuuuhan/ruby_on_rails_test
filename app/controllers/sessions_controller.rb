class SessionsController < ApplicationController
  def new
  end

  def login
    @user = User.find_by(email: params[:email])
    if @user&.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to tasks_path, notice: t("sessions.controller.login_success")
    else
      flash.now[:alert] = t("sessions.controller.login_fail")
      render :new, status: :unprocessable_entity
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to login_path, notice: t("sessions.controller.logout_success")
  end
end
