class AuditLogsController < ApplicationController
  def index
    result = with_api_retry { api_client.get("audit_logs", filter_params) }
    @audit_logs = result["audit_logs"] || []
    @meta = result["meta"] || {}
  end

  private

  def filter_params
    params.permit(:event, :user_id, :page).to_h.compact_blank
  end
end
