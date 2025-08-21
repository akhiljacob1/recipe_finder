class RecipeSearchService
  attr_reader :user_ingredients, :max_time, :results

  def initialize(ingredient_string, max_time = nil)
    @user_ingredients = parse_ingredients(ingredient_string)
    @max_time = max_time.to_i if max_time.present?
    @results = []
  end

  def call(limit: 5)
    # Start with base recipe scope
    recipes_scope = Recipe.all
    
    # Apply time filter if specified
    if @max_time.present?
      recipes_scope = recipes_scope.where("total_time <= ?", @max_time)
    end
    
    # If no ingredient search, return time-filtered results
    if @user_ingredients.empty?
      @results = recipes_scope.limit(limit)
      return @results
    end
    
    # Apply ingredient scoring to time-filtered recipes
    recipes_with_scores = recipes_scope.map do |recipe|
      score = calculate_match_score(recipe)
      { recipe: recipe, score: score }
    end
    
    # Sort by score (descending) and take top results
    @results = recipes_with_scores
                 .select { |item| item[:score] > 0 }  # Only recipes with at least one match
                 .sort_by { |item| -item[:score] }    # Sort by score descending
                 .first(limit)
                 .map { |item| item[:recipe] }
    
    @results
  end

  private

  def parse_ingredients(ingredient_string)
    return [] if ingredient_string.blank?
    
    ingredient_string
      .split(',')
      .map(&:strip)
      .map(&:downcase)
      .reject(&:blank?)
  end

  def calculate_match_score(recipe)
    return 0 unless recipe.ingredients&.any?
    
    recipe_ingredients = recipe.ingredients.map(&:downcase)
    matches = 0
    
    @user_ingredients.each do |user_ingredient|
      # Check for exact matches or partial matches
      if recipe_ingredients.any? { |recipe_ingredient| 
           recipe_ingredient.include?(user_ingredient) || user_ingredient.include?(recipe_ingredient)
         }
        matches += 1
      end
    end
    
    return 0 if matches == 0
    
    # Calculate weighted score: recipe efficiency (70%) + user coverage (30%)
    # This prioritizes recipes with fewer extra ingredients while still favoring
    # recipes that use more of what the user has available
    user_coverage = matches.to_f / @user_ingredients.length
    recipe_efficiency = matches.to_f / recipe_ingredients.length
    
    # Weighted score: recipe efficiency is primary factor
    score = (recipe_efficiency ** 0.7) * (user_coverage ** 0.3) * 100
    score.round(2)
  end
end
