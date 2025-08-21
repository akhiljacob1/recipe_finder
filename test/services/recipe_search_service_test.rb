require "test_helper"

class RecipeSearchServiceTest < ActiveSupport::TestCase
  def setup
    @service = RecipeSearchService.new("eggs, flour")
  end

  test "initializes with user ingredients" do
    assert_equal ["eggs", "flour"], @service.user_ingredients
  end

  test "parse_ingredients handles empty string" do
    service = RecipeSearchService.new("")
    assert_equal [], service.user_ingredients
  end

  test "parse_ingredients handles nil" do
    service = RecipeSearchService.new(nil)
    assert_equal [], service.user_ingredients
  end

  test "parse_ingredients handles whitespace and case" do
    service = RecipeSearchService.new("  EGGS , Flour  , , BUTTER ")
    assert_equal ["eggs", "flour", "butter"], service.user_ingredients
  end

  test "call returns empty array for empty ingredients" do
    service = RecipeSearchService.new("")
    assert_equal [], service.call
  end

  test "call returns recipes with at least one matching ingredient" do
    # Test with ingredients that match pancakes: flour, eggs
    service = RecipeSearchService.new("eggs, flour")
    results = service.call
    
    assert_includes results.map(&:title), "Fluffy Pancakes"
    assert_includes results.map(&:title), "Chocolate Chip Cookies"
  end

  test "call respects limit parameter" do
    service = RecipeSearchService.new("eggs")
    results = service.call(limit: 2)
    
    assert_operator results.length, :<=, 2
  end

  test "call sorts by match score descending" do
    # Pancakes has both flour and eggs (100% match)
    # Cookies has flour and eggs (100% match) 
    # Carbonara has only eggs (50% match if searching for "eggs, flour")
    service = RecipeSearchService.new("eggs, flour")
    results = service.call
    
    # Get the actual scores for debugging
    pancakes = recipes(:pancakes)
    cookies = recipes(:chocolate_chip_cookies)
    carbonara = recipes(:pasta_carbonara)
    
    pancake_score = service.send(:calculate_match_score, pancakes)
    cookie_score = service.send(:calculate_match_score, cookies)
    carbonara_score = service.send(:calculate_match_score, carbonara)
    
    # Both pancakes and cookies should have 46.35 score with weighted approach
    # (recipe_efficiency^0.7 * user_coverage^0.3) * 100
    # Pancakes/Cookies: (2/6)^0.7 * (2/2)^0.3 = 0.4635
    assert_equal 46.35, pancake_score
    assert_equal 46.35, cookie_score
    
    # Carbonara should have 26.33 score 
    # (1/5)^0.7 * (1/2)^0.3 = 0.2633
    assert_equal 26.33, carbonara_score
    
    # Results should be ordered by score (ties broken by whatever Rails uses for ordering)
    assert results.length > 0
    # The first results should be the highest scoring matches
    first_result_score = service.send(:calculate_match_score, results.first)
    assert_equal 46.35, first_result_score
  end

  test "calculate_match_score returns 0 for recipe with no ingredients" do
    recipe = Recipe.new(title: "Empty Recipe", ingredients: [])
    score = @service.send(:calculate_match_score, recipe)
    assert_equal 0, score
  end

  test "calculate_match_score returns 0 for recipe with nil ingredients" do
    recipe = Recipe.new(title: "Nil Recipe", ingredients: nil)
    score = @service.send(:calculate_match_score, recipe)
    assert_equal 0, score
  end

  test "calculate_match_score handles exact matches" do
    recipe = Recipe.new(ingredients: ["eggs", "flour"])
    service = RecipeSearchService.new("eggs, flour")
    score = service.send(:calculate_match_score, recipe)
    assert_equal 100.0, score
  end

  test "calculate_match_score handles partial matches" do
    # Recipe has "chicken breast", user searches for "chicken"
    # Weighted score: (1/2)^0.7 * (1/1)^0.3 = 61.56
    recipe = Recipe.new(ingredients: ["chicken breast", "rice"])
    service = RecipeSearchService.new("chicken")
    score = service.send(:calculate_match_score, recipe)
    assert_equal 61.56, score
  end

  test "calculate_match_score handles reverse partial matches" do
    # Recipe has "tomato", user searches for "cherry tomatoes"
    # Weighted score: (1/2)^0.7 * (1/1)^0.3 = 61.56
    recipe = Recipe.new(ingredients: ["tomato", "basil"])
    service = RecipeSearchService.new("cherry tomatoes")
    score = service.send(:calculate_match_score, recipe)
    assert_equal 61.56, score
  end

  test "calculate_match_score handles mixed case" do
    recipe = Recipe.new(ingredients: ["EGGS", "Flour"])
    service = RecipeSearchService.new("eggs, flour")
    score = service.send(:calculate_match_score, recipe)
    assert_equal 100.0, score
  end

  test "calculate_match_score calculates weighted score correctly" do
    # Recipe has eggs, flour, sugar. User has eggs, flour, butter.
    # Weighted score: (2/3)^0.7 * (2/3)^0.3 = 66.67
    recipe = Recipe.new(ingredients: ["eggs", "flour", "sugar"])
    service = RecipeSearchService.new("eggs, flour, butter")
    score = service.send(:calculate_match_score, recipe)
    assert_equal 66.67, score
  end

  test "integration test with realistic scenario" do
    # User wants to make something with eggs and flour
    service = RecipeSearchService.new("eggs, flour")
    results = service.call(limit: 5)
    
    # Should return pancakes and cookies (both have eggs and flour)
    result_titles = results.map(&:title)
    assert_includes result_titles, "Fluffy Pancakes"
    assert_includes result_titles, "Chocolate Chip Cookies"
    
    # Should not return stir fry (has neither eggs nor flour)
    refute_includes result_titles, "Quick Chicken Stir Fry"
  end

  test "handles single ingredient search" do
    service = RecipeSearchService.new("garlic")
    results = service.call
    
    result_titles = results.map(&:title)
    # Should return tomato soup and chicken stir fry (both have garlic)
    assert_includes result_titles, "Creamy Tomato Soup"
    assert_includes result_titles, "Quick Chicken Stir Fry"
  end

  test "handles no matches" do
    service = RecipeSearchService.new("quinoa")  # Not in any fixture
    results = service.call
    
    assert_equal [], results
  end

  test "handles complex ingredient names" do
    # Test with "parmesan cheese" from carbonara
    service = RecipeSearchService.new("parmesan cheese")
    results = service.call
    
    assert_includes results.map(&:title), "Classic Pasta Carbonara"
  end
end
