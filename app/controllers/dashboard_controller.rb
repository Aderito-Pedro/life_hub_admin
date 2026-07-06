class DashboardController < ApplicationController
  def show
    @stats = with_api_retry { api_client.get("/admin/dashboard") }
  end
end
