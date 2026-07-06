# URL base da API central (ad_life_hub). Esta aplicação não tem base de
# dados própria — é um cliente HTTP autenticado da API, tal como a app
# Flutter (ver docs/admin_panel_module.md no repositório da API).
Rails.application.config.x.lifehub_api_url = ENV.fetch("LIFEHUB_API_URL", "http://localhost:3000/api/v1/")
