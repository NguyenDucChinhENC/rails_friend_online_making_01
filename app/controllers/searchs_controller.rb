class SearchsController < ApplicationController
  include TransactionsHelper
  before_action :check_blocked_user, only: %i(index create)

  def index
    here_local = current_user.local
    @users = User.join_with_transaction_and_birthday.
      check_birthday(get_date_from_age(Settings.matching.max_age), get_date_from_age(Settings.matching.min_age)).
      check_position(Settings.matching.rad, current_user.local.latitude, current_user.local.longitude)
  end

  def create
    here_local = current_user.local
    @users = User.join_with_transaction_and_birthday.
      check_genre(params[:search][:genre] == "male" ? 0 : 1).
      check_birthday(get_date_from_age(params[:search][:age_max].to_i),
        get_date_from_age(params[:search][:age_min].to_i)).
      check_position(Settings.matching.rad, current_user.local.latitude,
          current_user.local.longitude)
  end

  private

  def check_params birthday
    u = birthday.user
    (u.genre == params[:search][:genre]) &&
    (age(birthday.birthday) <= params[:search][:age_max].to_i) &&
    (age(birthday.birthday) >= params[:search][:age_min].to_i) ? true : false
  end
end
