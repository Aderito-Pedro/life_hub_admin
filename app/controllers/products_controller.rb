class ProductsController < ApplicationController
  def index
    result = with_api_retry { api_client.get("admin/products", filter_params) }
    @products = result["products"] || []
    @meta = result["meta"] || {}
  end

  def new
    @product = {}
    load_categories
  end

  def create
    with_api_retry { api_client.post("admin/products", product_params) }
    redirect_to products_path, notice: "Produto criado com sucesso."
  rescue ApiClient::Error => e
    flash.now[:alert] = e.message
    @product = product_params
    load_categories
    render :new, status: :unprocessable_entity
  end

  def edit
    @product = with_api_retry { api_client.get("admin/products/#{params[:id]}") }["product"]
    load_categories
  end

  def update
    with_api_retry { api_client.patch("admin/products/#{params[:id]}", product_params) }
    redirect_to products_path, notice: "Produto actualizado com sucesso."
  rescue ApiClient::Error => e
    flash.now[:alert] = e.message
    @product = product_params.merge("id" => params[:id])
    load_categories
    render :edit, status: :unprocessable_entity
  end

  private

  def load_categories
    @categories = with_api_retry { api_client.get("admin/categories") }["categories"] || []
  end

  def filter_params
    params.permit(:category_id, :q, :page).to_h.compact_blank
  end

  def product_params
    params.require(:product).permit(:name, :slug, :description, :price, :category_id, :stock_quantity, :published, :active).to_h
  end
end
