require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as }

  test "lists categories from the API" do
    stub_request(:get, api_url("admin/categories")).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: { categories: [ { "id" => 1, "name" => "Casa", "slug" => "casa", "active" => true } ] }.to_json
    )

    get categories_path

    assert_response :success
    assert_match "Casa", response.body
  end

  test "creates a category" do
    stub_request(:post, api_url("admin/categories"))
      .with(body: { name: "Jardinagem", active: "1" })
      .to_return(status: 201, headers: { "Content-Type" => "application/json" }, body: { category: { "id" => 2, "name" => "Jardinagem" } }.to_json)

    post categories_path, params: { category: { name: "Jardinagem", active: "1" } }

    assert_redirected_to categories_path
  end

  test "re-renders the form with an error when creation fails" do
    stub_request(:post, api_url("admin/categories")).to_return(
      status: 422,
      headers: { "Content-Type" => "application/json" },
      body: { errors: [ "Name has already been taken" ] }.to_json
    )

    post categories_path, params: { category: { name: "Casa", active: "1" } }

    assert_response :unprocessable_entity
    assert_match "Name has already been taken", response.body
  end

  test "edits a category" do
    stub_request(:get, api_url("admin/categories/1")).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: { category: { "id" => 1, "name" => "Casa", "slug" => "casa", "active" => true } }.to_json
    )

    get edit_category_path(1)

    assert_response :success
    assert_match "value=\"Casa\"", response.body
  end
end
