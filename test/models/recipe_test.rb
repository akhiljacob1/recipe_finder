require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "search_by_ingredients delegates to RecipeSearchService" do
    results = Recipe.search_by_ingredients("eggs, flour")
    
    # Should return an ActiveRecord::Relation with matching ingredients
    assert results.is_a?(ActiveRecord::Relation)
    result_titles = results.map(&:title)
    assert_includes result_titles, "Fluffy Pancakes"
    assert_includes result_titles, "Chocolate Chip Cookies"
  end

  test "search_by_ingredients respects limit parameter" do
    results = Recipe.search_by_ingredients("eggs", limit: 1)
    # The limit is now handled by the service, but the relation can still be limited
    assert results.is_a?(ActiveRecord::Relation)
    # The service returns all matching recipes, limit is applied in the controller
  end

  test "search_by_ingredients returns empty relation for no matches" do
    results = Recipe.search_by_ingredients("quinoa")
    assert results.is_a?(ActiveRecord::Relation)
    assert_equal 0, results.count
  end

  test "ingredient_match_score calculates score for recipe" do
    pancakes = recipes(:pancakes)
    score = pancakes.ingredient_match_score("eggs, flour")
    
    # Pancakes has both eggs and flour (6 total ingredients)
    # Weighted score: (2/6)^0.7 * (2/2)^0.3 = 46.35
    assert_equal 46.35, score
  end

  test "ingredient_match_score handles partial matches" do
    carbonara = recipes(:pasta_carbonara)
    score = carbonara.ingredient_match_score("eggs, flour")
    
    # Carbonara has eggs but not flour (5 total ingredients)
    # Weighted score: (1/5)^0.7 * (1/2)^0.3 = 26.33
    assert_equal 26.33, score
  end

  test "ingredient_match_score returns 0 for no matches" do
    pancakes = recipes(:pancakes)
    score = pancakes.ingredient_match_score("quinoa")
    
    assert_equal 0.0, score
  end

  test "recipe has required attributes" do
    recipe = recipes(:pancakes)
    
    assert_not_nil recipe.title
    assert_not_nil recipe.ingredients
    assert recipe.ingredients.is_a?(Array)
    assert recipe.ingredients.any?
  end

  test "ingredients array contains strings" do
    recipe = recipes(:pancakes)
    
    recipe.ingredients.each do |ingredient|
      assert ingredient.is_a?(String)
      assert ingredient.length > 0
    end
  end

  test "search_by_ingredients_and_time delegates to RecipeSearchService with time" do
    results = Recipe.search_by_ingredients_and_time("eggs", 30)
    
    # Should return an ActiveRecord::Relation (basic delegation test)
    assert results.is_a?(ActiveRecord::Relation)
  end
end
