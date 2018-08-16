class UsersController < ApplicationController
  before_action :check_blocked_user, only: %i(timeline_friends create edit update show new destroy)
  before_action :correct_user, :get_new_report, only: %i(show edit update show_desire show_public
    show_private timeline_friends show_posts)
  before_action :user_params, only: :update
  before_action :relationship, only: %i(show show_private show_desire show_public
    timeline_friends)
  before_action :check_right, only: %i(show_desire show_private)
  before_action :find_conection, only: %i(show show_public show_private show_desire)

  def timeline_friends
    @user.conections
    @friends = User.get_friends(current_user)
  end

  def show
    @blogs = @user.blogs.ordered_by_created_at.page(params[:page]).per Settings.pagination.report
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @email = @user.build_email email_params
      if @email.save
        tables = [:birthday, :career, :body, :education, :desire]
        tables.each do |tbl|
          param_g = params.require(:user).permit tbl.capitalize.to_s.constantize::ATTRIBUTES_PARAMS
          @user.send("build_#{tbl}", param_g).save
        end
        create_default_tracsaction
        log_in @user
        flash[:success] = t("sign_up_success")
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
      flash[:success] = t("logout_success")
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

  def edit_email
    @user = User.find params[:id]
    @email = Email.find_by user_id: @user.id
    email = @email.email
  end

  def load_user
    @user = current_user
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
    return if @conection&.status || @user = current_user
    render :show_public
  end

  def find_conection
    if logged_in?
      @conection = Conection.find_follow(current_user.id, @user.id).first
      @followed = @conection.present? ? @conection : false
      @follow = Conection.find_follow(current_user.id, @user.id)
      if current_user?(@user)
        conections = Conection.find_want_follow(current_user)
        @wanteds = User.join_with_conections.check_conection(current_user).ordered_by_created_at
      end
    end
  end

  def get_new_report
    @report = Report.new
  end
end
