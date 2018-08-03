class SearchsController < ApplicationController
  before_action :check_login

  def index
    here_local = current_user.local
    local_nearbys = here_local.nearbys(50)
    @users = [];
    local_nearbys.each do |local|
      user = local.user
      birthday = user.birthday
      if birthday&.birthday.present? 
        if check_user(birthday, "male", 30, 1)
          @users.push user
        end
      end
    end
  end

  def create
  end

  private
  def check_login
    return if logged_in?
    redirect_to root_url
  end

  def age dob
    now = Time.now.utc.to_date
    t = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    t.to_i
  end

  def check_user(b, genre, max_age, min_age)
    u = b.user
    (u.genre != current_user.genre) && (age(b.birthday) <= max_age) && (age(b.birthday) >= min_age) ? true : false
  end
end
