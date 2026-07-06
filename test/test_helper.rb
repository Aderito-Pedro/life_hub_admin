ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"

WebMock.disable_net_connect!(allow_localhost: false)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    def api_url(path)
      "#{ApiClient.base_url}#{path.delete_prefix("/")}"
    end
  end
end

module StaffSessionHelper
  def sign_in_as(id: 1, full_name: "Bruno Sacramento", email: "bruno@lifehub.test", role: "admin")
    user = { "id" => id, "full_name" => full_name, "email" => email, "role" => role }
    stub_request(:post, api_url("/login"))
      .with(body: hash_including("email" => email))
      .to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: { user: user, token: "access-token", refresh_token: "refresh-token" }.to_json
    )

    post login_path, params: { email: email, password: "Secret123!" }
    user
  end
end

ActionDispatch::IntegrationTest.include StaffSessionHelper
