class ConectionsController < ApplicationController
  before_action :check_blocked_user, only: %i(create update destroy)
  before_action :correct_follow, only: %i(update destroy)

  def create
    @followed = check_conected params[:conection][:recipient_id]
    unless @followed
      @conection = current_user.conections.new conection_params
      if @conection.save
        @user =User.find_by id: @conection.recipient_id
        conections_respond
      end
    end
  end

  def update
    @conection.update_attributes status: true
    @user = User.find_by id: @conection.recipient_id
    check_unique = Conversation.between(@conection.sender_id, @conection.recipient_id)
    if check_unique.present?
      conversation = current_user.conversations.new recipient_id: @conection.sender_id
      if conversation.save
        conections_respond
      else
        @conection.update_attributes status: false
      end
    end

    conections_respond
  end

  def destroy
    if @conection.present?
      @user =User.find_by id: @conection.recipient_id
      @conection.destroy
      conections_respond
    end
  end

  private

  def correct_follow
    @conection = Conection.find_by id: params[:conection][:id]
    return if @conection
    redirect_to root_path
  end

  def conection_params
    params.require(:conection).permit :recipient_id
  end

  def check_conected recipient_id
    current_user.conections.find_by recipient_id: recipient_id
  end

  def conections_respond
    respond_to do |format|
      format.html {redirect_to root_path}
      format.js
    end
  end
end
