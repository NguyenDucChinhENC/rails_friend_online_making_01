class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(edit update show)
  before_action :correct_user, only: %i(show edit update show_desire show_public
    show_private timeline_friends)
  before_action :user_params, only: :update
  before_action :relationship, only: %i(show show_private show_desire show_public
    timeline_friends)
  before_action :check_right, only: %i(show_desire show_private)
  before_action :find_conection, only: %i(show show_public show_private show_desire)

  def timeline_friends
    @user.conections
  end

  def show
    @blogs = @user.blogs.page(params[:page]).per Settings.pagination.report
    @blogs = @blogs.reverse
  end

  def show_public
  end

  def show_private
  end

  def show_desire
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @email = @user.build_email email_params
      if @email.save
        @birthday = @user.build_birthday birthday_params
        @birthday.save
        @career = @user.build_career career_params
        @career.save
        @body = @user.build_body body_params
        @body.save
        @education = @user.build_education education_params
        @education.save
        @desire = @user.build_desire desire_params
        @desire.save
        create_default_tracsaction
        log_in @user
        flash[:success] = t("success")
        redirect_to @user
      else
        @user.destroy
        render :new
      end
    else
      render :new
    end
  end

  def edit
    @email = Email.find_by user_id: @user.id
    @email = @user.email
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t("success")
    else
      flash[:warning] = t("error")
    end
    redirect_to users_url
  end

  private

  def correct_user
    @user = User.find_by id: params[:id]
    return if @user.present?
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit User::ATTRIBUTES_PARAMS
  end

  def email_params
    params.require(:user).permit Email::ATTRIBUTES_PARAMS
  end

  def birthday_params
    params.require(:user).permit Birthday::ATTRIBUTES_PARAMS
  end

  def education_params
    params.require(:user).permit Education::ATTRIBUTES_PARAMS
  end

  def body_params
    params.require(:user).permit Body::ATTRIBUTES_PARAMS
  end

  def career_params
    params.require(:user).permit Career::ATTRIBUTES_PARAMS
  end

  def desire_params
    params.require(:user).permit Desire::ATTRIBUTES_PARAMS
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t("users.logged_in_user.danger")
      redirect_to login_url
    end
  end

  def edit_email
    @user = User.find params[:id]
    @email = Email.find_by user_id: @user.id
    email = @email.email
  end

  def create_default_tracsaction
    @local = @user.build_local
    @local.latitude = 20.9
    @local.longitude = 105.9
    return if @local.save
    @user.destroy
    redirect_to root_url
  end

  def relationship
    if logged_in?
      @conection = Conection.find_follow(current_user.id, @user.id).first
      @conection? @followed = @conection : @followed = false
    end
  end

  def check_right
    return if @conection&.status
    render :show_public
  end
  def find_conection
    if logged_in?
      @conection = Conection.find_follow(current_user.id, @user.id).first
      @conection? @followed = @conection : @followed = false
      @follow = Conection.find_follow(current_user.id, @user.id)
      if current_user.id == @user.id
        conections = Conection.find_want_follow(current_user)
        @wanteds = []
        conections.each do |conection|
          @wanteds.push User.find_by id: conection.sender_id
        end
      end
    end
  end
end
