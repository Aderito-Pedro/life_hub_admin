class CategoriesController < ApplicationController
  def index
    @categories = with_api_retry { api_client.get("admin/categories") }["categories"] || []
  end

  def new
    @category = {}
  end

  def create
    with_api_retry { api_client.post("admin/categories", category_params) }
    redirect_to categories_path, notice: "Categoria criada com sucesso."
  rescue ApiClient::Error => e
    flash.now[:alert] = e.message
    @category = category_params
    render :new, status: :unprocessable_entity
  end

  def edit
    @category = with_api_retry { api_client.get("admin/categories/#{params[:id]}") }["category"]
  end

  def update
    with_api_retry { api_client.patch("admin/categories/#{params[:id]}", category_params) }
    redirect_to categories_path, notice: "Categoria actualizada com sucesso."
  rescue ApiClient::Error => e
    flash.now[:alert] = e.message
    @category = category_params.merge("id" => params[:id])
    render :edit, status: :unprocessable_entity
  end

  private

  def category_params
    params.require(:category).permit(:name, :slug, :description, :active).to_h
  end
end
