class RecipeSearchService
  attr_reader :user_ingredients, :results

  def initialize(ingredient_string)
    @user_ingredients = parse_ingredients(ingredient_string)
    @results = []
  end

  def call(limit: 5)
    return [] if @user_ingredients.empty?
    
    recipes_with_scores = Recipe.all.map do |recipe|
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
    
    # Calculate score as percentage of user ingredients matched
    # This prioritizes recipes that match more of what the user has
    (matches.to_f / @user_ingredients.length * 100).round(2)
  end
end
