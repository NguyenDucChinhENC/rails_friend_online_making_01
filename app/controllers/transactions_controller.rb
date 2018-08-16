class TransactionsController < ApplicationController
  include TransactionsHelper
  before_action :check_blocked_user, only: %i(index create)

  def index
    @tran = current_user.local
    @transactions = Transaction.near(@tran)
  end

  def create
    local = current_user.local
    if local.update_attributes location_params
      @tran = local
      @transactions = Transaction.near(@tran)
      respond_to do |format|
        format.js
        format.html { redirect_to root_path }
      end
    end
  end

  private

  def location_params
     params.require(:local).permit Transaction::ATTRIBUTES_PARAMS
  end
end
