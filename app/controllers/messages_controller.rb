class MessagesController < ApplicationController
  before_action :check_blocked_user, only: %i(new create)
  before_action :check_exist_conversation, only: %i(create)

  def new;  end

  def create
    @message = @conversation.messages.build message_params.merge(user: current_user)
    if @message.save
      # Send to boardcast
      @message_for_sender = render_to_string(
        template: "messages/_message",
        locals: {message: @message},
        layout: false
      )

      @message_for_recipient = render_to_string(
        template: "messages/_message_recipient",
        locals: {message: @message},
        layout: false
      )

      ActionCable.server.broadcast "conversation_#{@conversation.id}",
        message_for_recipient: @message_for_recipient,
        message_for_sender: @message_for_sender,
        sender_id: current_user.id,
        conversation_id: @conversation.id,
        body: @message.body
    end
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end

  def check_exist_conversation
    @conversation = Conversation.find_by id: params[:conversation_id]
    return if @conversation.present?
    redirect_to root_url
  end
end
