class ApplicationController < ActionController::Base
  STAFF_ROLES = %w[admin supervisor operator].freeze

  class SessionExpired < StandardError; end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :require_staff_session

  rescue_from SessionExpired, with: :handle_session_expired
  rescue_from ApiClient::Forbidden, with: :handle_forbidden
  rescue_from ApiClient::NotFound, with: :handle_not_found
  rescue_from ApiClient::Error, with: :handle_api_error

  helper_method :current_staff, :current_staff_role

  private

  def require_staff_session
    return if session[:access_token].present? && session[:staff_user].present?

    redirect_to login_path, alert: "Autentique-se para continuar."
  end

  def current_staff
    session[:staff_user]
  end

  def current_staff_role
    current_staff && current_staff["role"]
  end

  def api_client
    @api_client ||= ApiClient.new(access_token: session[:access_token])
  end

  # Executa uma chamada à API tolerando um único refresh de token: se o
  # access token tiver expirado, tenta rodar o par de tokens uma vez e
  # repete o pedido — o mesmo padrão do interceptor Dio da app Flutter.
  def with_api_retry
    yield
  rescue ApiClient::Unauthorized
    raise SessionExpired unless refresh_session_token!

    begin
      yield
    rescue ApiClient::Unauthorized
      raise SessionExpired
    end
  end

  def refresh_session_token!
    return false if session[:refresh_token].blank?

    result = ApiClient.new.post("/refresh", { refresh_token: session[:refresh_token] })
    session[:access_token] = result["token"]
    session[:refresh_token] = result["refresh_token"]
    @api_client = nil
    true
  rescue ApiClient::Error
    false
  end

  def handle_session_expired
    reset_session
    redirect_to login_path, alert: "Sessão expirada. Autentique-se novamente."
  end

  def handle_forbidden(exception)
    redirect_to root_path, alert: exception.message.presence || "Não tem permissão para executar esta ação."
  end

  def handle_not_found
    redirect_to root_path, alert: "Recurso não encontrado."
  end

  def handle_api_error(exception)
    redirect_back fallback_location: root_path, alert: exception.message
  end
end
