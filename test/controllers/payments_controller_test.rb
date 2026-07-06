require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as }

  test "processes a refund and redirects back" do
    stub_request(:post, api_url("payments/9/refund"))
      .with(body: { reason: "cliente cancelou" })
      .to_return(status: 201, headers: { "Content-Type" => "application/json" }, body: { refund: { "id" => 1 }, payment: { "id" => 9, "status" => "refunded" } }.to_json)

    post refund_payment_path(9), params: { reason: "cliente cancelou" }, headers: { "HTTP_REFERER" => order_url(1) }

    assert_redirected_to order_url(1)
    assert_equal "Reembolso processado com sucesso.", flash[:notice]
  end

  test "redirects with an alert when the refund is rejected" do
    stub_request(:post, api_url("payments/9/refund")).to_return(
      status: 422,
      headers: { "Content-Type" => "application/json" },
      body: { error: "Este pagamento não pode ser reembolsado" }.to_json
    )

    post refund_payment_path(9), params: { reason: "tarde demais" }

    assert_redirected_to root_path
    assert_equal "Este pagamento não pode ser reembolsado", flash[:alert]
  end
end
