class ReportsController < ApplicationController
  before_action :check_blocked_user, only: %i(create)

  def create
    @report = Report.new report_params.merge(user: current_user)
    if @report.save
      @status = true
    else
      @status = false
    end

    respond_to do |format|
      format.js {}
    end
  end

  private
  def report_params
    params.require(:report).permit Report::ATTRIBUTES_PARAMS
  end
end
