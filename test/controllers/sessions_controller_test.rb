require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "renders the login page without requiring a session" do
    get login_path

    assert_response :success
  end

  test "logs in a staff member and redirects to the dashboard" do
    stub_request(:post, api_url("/login"))
      .with(body: { email: "bruno@lifehub.test", password: "Secret123!", device_name: "LifeHub Admin", device_type: "web" })
      .to_return(
        status: 200,
        headers: { "Content-Type" => "application/json" },
        body: {
          user: { "id" => 1, "full_name" => "Bruno Sacramento", "email" => "bruno@lifehub.test", "role" => "admin" },
          token: "access-token",
          refresh_token: "refresh-token"
        }.to_json
      )

    post login_path, params: { email: "bruno@lifehub.test", password: "Secret123!" }

    assert_redirected_to root_path

    stub_request(:get, api_url("/admin/dashboard")).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: {
        users: { total: 1, by_role: { "admin" => 1 } },
        orders: { total: 0, by_status: {} },
        payments: { approved_total: 0, pending_count: 0 },
        audit: { last_24h_count: 0, recent: [] }
      }.to_json
    )
    follow_redirect!
    assert_response :success
  end

  test "rejects a login from a non-staff role" do
    stub_request(:post, api_url("/login")).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: {
        user: { "id" => 2, "full_name" => "Marta Dias", "email" => "marta@lifehub.test", "role" => "customer" },
        token: "access-token",
        refresh_token: "refresh-token"
      }.to_json
    )

    post login_path, params: { email: "marta@lifehub.test", password: "Secret123!" }

    assert_response :unprocessable_entity
    assert_match "exclusiva", response.body
  end

  test "rejects invalid credentials with the API error message" do
    stub_request(:post, api_url("/login")).to_return(
      status: 401,
      headers: { "Content-Type" => "application/json" },
      body: { error: "Credenciais inválidas" }.to_json
    )

    post login_path, params: { email: "bruno@lifehub.test", password: "wrong" }

    assert_response :unprocessable_entity
    assert_match "Credenciais inválidas", response.body
  end

  test "logout clears the session" do
    sign_in_as
    stub_request(:delete, api_url("/logout")).to_return(status: 200, headers: { "Content-Type" => "application/json" }, body: "{}")

    delete logout_path

    assert_redirected_to login_path
    get dashboard_path
    assert_redirected_to login_path
  end

  test "redirects to login when there is no session" do
    get dashboard_path

    assert_redirected_to login_path
  end
end
