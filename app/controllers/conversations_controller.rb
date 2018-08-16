class ConversationsController < ApplicationController
  before_action :check_blocked_user, :get_conversations, only: %i(index show)
  before_action :get_current_conversation,
    :allowed?, only: %i(show)

  def index
    redirect_to action: :show, id: @conversations.last.id if @conversations.last.present?
  end

  def show
    @messages = Message.message_asc.where conversation_id: params[:id]
  end

  private

  def allowed?
    return if @current_conversation.sender == current_user ||
      @current_conversation.recipient == current_user

    redirect_to root_url
  end

  def get_conversations
    @conversations = Conversation.get_all(current_user.id)
  end

  def get_current_conversation
    @current_conversation = Conversation.find_by id: params[:id]

    redirect_to action: :index if @current_conversation.nil?
  end
end
