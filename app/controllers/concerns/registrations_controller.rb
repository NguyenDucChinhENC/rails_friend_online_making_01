class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
  	super
    if @user.present?
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
    else
      render :new
    end
  end

  def update
    super
  end

  private

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
