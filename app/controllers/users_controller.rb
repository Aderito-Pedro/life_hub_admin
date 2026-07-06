class UsersController < ApplicationController
  def index
    result = with_api_retry { api_client.get("admin/users", filter_params) }
    @users = result["users"] || []
    @meta = result["meta"] || {}
  end

  def show
    result = with_api_retry { api_client.get("admin/users/#{params[:id]}") }
    @user = result["user"]
  end

  def update
    with_api_retry { api_client.patch("admin/users/#{params[:id]}", update_params) }
    redirect_to user_path(params[:id]), notice: "Utilizador actualizado com sucesso."
  end

  private

  def filter_params
    params.permit(:role, :status, :q, :page).to_h.compact_blank
  end

  def update_params
    params.permit(:role, :status).to_h.compact_blank
  end
end
