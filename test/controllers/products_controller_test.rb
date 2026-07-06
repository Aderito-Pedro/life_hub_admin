require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as }

  test "lists products from the API" do
    stub_request(:get, api_url("admin/products"))
      .with(query: hash_including({}))
      .to_return(
        status: 200,
        headers: { "Content-Type" => "application/json" },
        body: { products: [ { "id" => 1, "name" => "Mesa", "price" => 30_000, "stock_quantity" => 5, "published" => true } ], meta: { "count" => 1 } }.to_json
      )

    get products_path

    assert_response :success
    assert_match "Mesa", response.body
  end

  test "renders the new product form with categories" do
    stub_request(:get, api_url("admin/categories")).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: { categories: [ { "id" => 1, "name" => "Casa" } ] }.to_json
    )

    get new_product_path

    assert_response :success
    assert_match "Casa", response.body
  end

  test "creates a product" do
    stub_request(:post, api_url("admin/products")).to_return(
      status: 201,
      headers: { "Content-Type" => "application/json" },
      body: { product: { "id" => 2, "name" => "Cadeira" } }.to_json
    )

    post products_path, params: { product: { name: "Cadeira", price: 15_000, category_id: 1, published: "1", active: "1" } }

    assert_redirected_to products_path
  end

  test "edits a product" do
    stub_request(:get, api_url("admin/products/1")).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: { product: { "id" => 1, "name" => "Mesa", "price" => 30_000, "category_id" => 1, "published" => false } }.to_json
    )
    stub_request(:get, api_url("admin/categories")).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: { categories: [ { "id" => 1, "name" => "Casa" } ] }.to_json
    )

    get edit_product_path(1)

    assert_response :success
    assert_match "value=\"Mesa\"", response.body
  end
end
