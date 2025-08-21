class Recipe < ApplicationRecord
  def self.search_by_ingredients(ingredient_string, limit: 5)
    RecipeSearchService.new(ingredient_string).call(limit: limit)
  end

  def self.search_by_ingredients_and_time(ingredient_string, max_time, limit: 50)
    RecipeSearchService.new(ingredient_string, max_time).call(limit: limit)
  end
  
  def ingredient_match_score(user_ingredients_string)
    service = RecipeSearchService.new(user_ingredients_string)
    user_ingredients = service.send(:parse_ingredients, user_ingredients_string)
    service.send(:calculate_match_score, self)
  end
end
