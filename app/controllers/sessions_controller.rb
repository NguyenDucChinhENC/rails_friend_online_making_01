class SessionsController < ApplicationController
  before_action :load_user, only: %i(create)

  def new; end

  def show; end

  def create
    email = Email.find_by email: params[:session][:email].downcase
    user = email.user
    if user&.authenticate(params[:session][:password])
      log_in user
      # params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      redirect_back_or user
    else
      flash[:danger] = t(".danger")
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to login_path
  end

  private

  def load_user
    @email = Email.find_by email: params[:session][:email].downcase
    return if @email
    flash[:fail] = t("sessions.load_user.fail")
    redirect_to login_path
  end
end
