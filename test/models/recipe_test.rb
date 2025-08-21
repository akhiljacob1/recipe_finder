require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "search_by_ingredients delegates to RecipeSearchService" do
    results = Recipe.search_by_ingredients("eggs, flour")
    
    # Should return recipes with matching ingredients
    assert results.is_a?(Array)
    result_titles = results.map(&:title)
    assert_includes result_titles, "Fluffy Pancakes"
    assert_includes result_titles, "Chocolate Chip Cookies"
  end

  test "search_by_ingredients respects limit parameter" do
    results = Recipe.search_by_ingredients("eggs", limit: 1)
    assert_equal 1, results.length
  end

  test "search_by_ingredients returns empty array for no matches" do
    results = Recipe.search_by_ingredients("quinoa")
    assert_equal [], results
  end

  test "ingredient_match_score calculates score for recipe" do
    pancakes = recipes(:pancakes)
    score = pancakes.ingredient_match_score("eggs, flour")
    
    # Pancakes has both eggs and flour, so should be 100%
    assert_equal 100.0, score
  end

  test "ingredient_match_score handles partial matches" do
    carbonara = recipes(:pasta_carbonara)
    score = carbonara.ingredient_match_score("eggs, flour")
    
    # Carbonara has eggs but not flour, so should be 50%
    assert_equal 50.0, score
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
end
