require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as }

  test "lists orders from the API" do
    stub_request(:get, api_url("orders"))
      .with(query: hash_including({}))
      .to_return(
        status: 200,
        headers: { "Content-Type" => "application/json" },
        body: { orders: [ { "id" => 1, "status" => "paid", "payment_status" => "paid", "total_amount" => 30_000 } ], meta: { "count" => 1 } }.to_json
      )

    get orders_path

    assert_response :success
    assert_match "#1", response.body
  end

  test "shows an order with its payment and a refund button when approved" do
    stub_request(:get, api_url("orders/1")).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: { order: { "id" => 1, "status" => "paid", "payment_status" => "paid", "total_amount" => 30_000, "items" => [] } }.to_json
    )
    stub_request(:get, api_url("orders/1/payment")).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: { payment: { "id" => 9, "status" => "approved", "amount" => 30_000, "transactions" => [] } }.to_json
    )

    get order_path(1)

    assert_response :success
    assert_match "Reembolsar", response.body
  end

  test "shows an order without a payment yet" do
    stub_request(:get, api_url("orders/2")).to_return(
      status: 200,
      headers: { "Content-Type" => "application/json" },
      body: { order: { "id" => 2, "status" => "pending", "payment_status" => "unpaid", "total_amount" => 10_000, "items" => [] } }.to_json
    )
    stub_request(:get, api_url("orders/2/payment")).to_return(
      status: 404,
      headers: { "Content-Type" => "application/json" },
      body: { error: "Nenhum pagamento encontrado para este pedido" }.to_json
    )

    get order_path(2)

    assert_response :success
    assert_match "não foi iniciado", response.body
  end
end
