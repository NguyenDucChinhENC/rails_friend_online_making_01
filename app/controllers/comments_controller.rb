class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :check_blocked_user, only: %i(show create edit)
  before_action :correct_comment, only: %i(show edit)

  def show
  end

  def create
    @comment = current_user.comments.new comment_params
    if @comment.save
      @support = Supports::CommentSupport.new(@comment, current_user)
      respond_to do |format|
        format.js
        format.html { redirect_to root_path }
      end
    end
  end

  def edit
  end

  private

  def comment_params
    params.require(:comment).permit Comment::ATTRIBUTES_PARAMS
  end

  def correct_comment
    @comment = Comment.find_by id: params[:id]
    return if @comment.present?
    redirect_to root_url
  end

  def check_rights_delete
    rights_delete @comment, current_user
  end

  def check_rights_update
    rights_update @comment, current_user
  end

  def comment_serializer comment
    Serializers::Comment::CommentsSerializer.new(object: comment).serializer
  end
end
