class OrdersController < ApplicationController
  def index
    result = with_api_retry { api_client.get("orders", filter_params) }
    @orders = result["orders"] || []
    @meta = result["meta"] || {}
  end

  def show
    @order = with_api_retry { api_client.get("orders/#{params[:id]}") }["order"]
    @payment = fetch_payment
  end

  private

  def fetch_payment
    with_api_retry { api_client.get("orders/#{params[:id]}/payment") }["payment"]
  rescue ApiClient::NotFound
    nil
  end

  def filter_params
    params.permit(:page).to_h.compact_blank
  end
end
