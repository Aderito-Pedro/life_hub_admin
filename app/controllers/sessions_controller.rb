class SessionsController < ApplicationController
  layout "sessions"
  skip_before_action :require_staff_session

  def new
  end

  def create
    result = ApiClient.new.post("/login", login_params.merge(device_name: "LifeHub Admin", device_type: "web"))
    user = result["user"] || {}

    unless STAFF_ROLES.include?(user["role"])
      flash.now[:alert] = "Esta aplicação é exclusiva para a equipa LifeHub Angola."
      return render :new, status: :unprocessable_entity
    end

    session[:access_token] = result["token"]
    session[:refresh_token] = result["refresh_token"]
    session[:staff_user] = user.slice("id", "full_name", "email", "role")

    redirect_to root_path, notice: "Sessão iniciada com sucesso."
  rescue ApiClient::Error => e
    flash.now[:alert] = e.message.presence || "Credenciais inválidas."
    render :new, status: :unprocessable_entity
  end

  def destroy
    ApiClient.new(access_token: session[:access_token]).delete("/logout") if session[:access_token].present?
    reset_session
    redirect_to login_path, notice: "Sessão terminada."
  rescue ApiClient::Error
    reset_session
    redirect_to login_path, notice: "Sessão terminada."
  end

  private

  def login_params
    params.permit(:email, :password).to_h
  end
end
