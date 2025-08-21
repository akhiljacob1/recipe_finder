class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show ]

  # GET /recipes or /recipes.json
  def index
    @search_query = params[:ingredients]
    @max_time = params[:max_time]
    
    if @search_query.present? || @max_time.present?
      recipes = Recipe.search_by_ingredients_and_time(@search_query, @max_time)
    else
      recipes = Recipe.all
    end
    
    # Store total count before pagination for display
    @total_count = recipes.count
    
    # Paginate results with 12 per page
    @pagy, @recipes = pagy(recipes, items: 12)
  end

  # GET /recipes/1 or /recipes/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = Recipe.find(params.expect(:id))
    end
end
