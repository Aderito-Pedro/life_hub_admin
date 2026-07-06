require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @staff = sign_in_as(role: "admin")
  end

  test "lists users from the API" do
    stub_request(:get, api_url("admin/users"))
      .with(query: hash_including({}))
      .to_return(
        status: 200,
        headers: { "Content-Type" => "application/json" },
        body: { users: [ { "id" => 2, "full_name" => "Marta Dias", "email" => "marta@lifehub.test", "role" => "customer", "status" => "active" } ], meta: { "count" => 1 } }.to_json
      )

    get users_path

    assert_response :success
    assert_match "Marta Dias", response.body
  end

  test "shows a user with the role change form for admins" do
    stub_request(:get, api_url("admin/users/2")).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: { user: { "id" => 2, "full_name" => "Marta Dias", "email" => "marta@lifehub.test", "role" => "customer", "status" => "active" } }.to_json
    )

    get user_path(2)

    assert_response :success
    assert_match "Alterar perfil", response.body
  end

  test "updates a user's status" do
    stub_request(:patch, api_url("admin/users/2"))
      .with(body: { status: "suspended" })
      .to_return(status: 200, headers: { "Content-Type" => "application/json" }, body: { user: { "id" => 2, "status" => "suspended" } }.to_json)

    patch user_path(2), params: { status: "suspended" }

    assert_redirected_to user_path(2)
  end

  test "redirects with an alert when the API rejects the update" do
    stub_request(:patch, api_url("admin/users/2"))
      .with(body: { role: "admin" })
      .to_return(status: 403, headers: { "Content-Type" => "application/json" }, body: { error: "Não tem permissão para executar esta ação" }.to_json)

    patch user_path(2), params: { role: "admin" }

    assert_redirected_to root_path
    assert_equal "Não tem permissão para executar esta ação", flash[:alert]
  end
end
