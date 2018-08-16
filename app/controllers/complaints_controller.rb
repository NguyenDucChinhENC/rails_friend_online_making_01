class ComplaintsController < ApplicationController
  before_action :check_correct_user, only: %i(index create)

  def index
    @complaint = Complaint.new
  end

  def create
    @complaint = current_user.complaints.new complaint_params
    @status = @complaint.save ? true : false

    respond_to :js
  end

  private

  def complaint_params
    params.require(:complaint).permit :content
  end

  def check_correct_user
    return if current_user.is_blocked?
    redirect_to root_path
  end
end
