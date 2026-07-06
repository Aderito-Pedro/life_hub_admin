class PaymentsController < ApplicationController
  def refund
    with_api_retry { api_client.post("payments/#{params[:id]}/refund", { reason: params[:reason] }) }
    redirect_back fallback_location: root_path, notice: "Reembolso processado com sucesso."
  end
end
