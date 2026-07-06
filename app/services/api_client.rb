# Cliente HTTP fino sobre a API central (ad_life_hub). Esta app não acede a
# nenhuma base de dados directamente — todos os dados vêm daqui.
class ApiClient
  class Error < StandardError
    attr_reader :status, :body

    def initialize(message, status: nil, body: nil)
      super(message)
      @status = status
      @body = body
    end
  end

  class Unauthorized < Error; end
  class Forbidden < Error; end
  class NotFound < Error; end

  # Faraday resolve caminhos absolutos ("/x") substituindo TODO o path da
  # base URL (RFC 3986) — perderíamos o "/api/v1". Por isso a base termina
  # sempre em "/" e os caminhos nunca começam por "/".
  def self.base_url
    Rails.application.config.x.lifehub_api_url.to_s.sub(%r{/*\z}, "/")
  end

  def initialize(access_token: nil)
    @access_token = access_token
  end

  def get(path, params = {})
    handle { connection.get(normalize(path), params) }
  end

  def post(path, body = {})
    handle { connection.post(normalize(path)) { |req| req.body = body } }
  end

  def patch(path, body = {})
    handle { connection.patch(normalize(path)) { |req| req.body = body } }
  end

  def delete(path)
    handle { connection.delete(normalize(path)) }
  end

  private

  def normalize(path)
    path.to_s.delete_prefix("/")
  end

  def connection
    @connection ||= Faraday.new(url: self.class.base_url) do |f|
      f.request :json
      f.response :json, content_type: /\bjson$/
      f.headers["Authorization"] = "Bearer #{@access_token}" if @access_token
      f.adapter Faraday.default_adapter
    end
  end

  def handle
    response = yield
    raise_for_status!(response)
    response.body.is_a?(Hash) ? response.body : {}
  end

  def raise_for_status!(response)
    return if response.success?

    data = response.body
    message = data.is_a?(Hash) ? (data["error"] || Array(data["errors"]).join(", ")) : nil
    message = message.presence || "Erro inesperado (#{response.status})"

    case response.status
    when 401 then raise Unauthorized.new(message, status: 401, body: data)
    when 403 then raise Forbidden.new(message, status: 403, body: data)
    when 404 then raise NotFound.new(message, status: 404, body: data)
    else raise Error.new(message, status: response.status, body: data)
    end
  end
end
