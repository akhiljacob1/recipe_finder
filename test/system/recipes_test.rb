require "application_system_test_case"

class RecipesTest < ApplicationSystemTestCase
  setup do
    @recipe = recipes(:pancakes)
  end

  test "visiting the index" do
    visit recipes_url
    assert_selector "h1", text: "Find Your Perfect Recipe"
  end

  test "searching for recipes by ingredients" do
    visit recipes_url
    
    # Should see the search form
    assert_selector "form"
    assert_selector "input[name='ingredients']"
    assert_selector "input[type='submit']"
    
    # Search for eggs and flour
    fill_in "ingredients", with: "eggs, flour"
    click_button "Find Recipes"
    
    # Should see search results
    assert_text "Found"
    assert_text "matching recipes"
    
    # Should see the matching recipes (100% matches appear first)
    assert_text "Fluffy Pancakes"
    assert_text "Chocolate Chip Cookies"
    # Carbonara appears too (50% match - has eggs but not flour)
    assert_text "Classic Pasta Carbonara"
    
    # Should not see non-matching recipes
    assert_no_text "Quick Chicken Stir Fry"
  end

  test "searching with single ingredient" do
    visit recipes_url
    
    fill_in "ingredients", with: "garlic"
    click_button "Find Recipes"
    
    # Should see search results with garlic-containing recipes
    assert_text "Creamy Tomato Soup"  # has garlic
    assert_text "Quick Chicken Stir Fry"  # has garlic
  end

  test "searching with no matches" do
    visit recipes_url
    
    fill_in "ingredients", with: "quinoa"
    click_button "Find Recipes"
    
    # Should see search query but no results
    assert_text "Found 0 matching recipes"
    
    # Should not see any recipe titles
    assert_no_text "Fluffy Pancakes"
    assert_no_text "Chocolate Chip Cookies"
  end

  test "clearing search shows all recipes" do
    visit recipes_url
    
    # First do a search
    fill_in "ingredients", with: "eggs"
    click_button "Find Recipes"
    
    # Click "Show All Recipes" link
    click_link "Show All Recipes"
    
    # Should see all recipes again
    assert_text "Fluffy Pancakes"
    assert_text "Quick Chicken Stir Fry"
    assert_text "Creamy Tomato Soup"
  end

  test "search form preserves search query" do
    visit recipes_url
    
    fill_in "ingredients", with: "tomatoes, cheese"
    click_button "Find Recipes"
    
    # The search field should still contain the search query
    assert_field "ingredients", with: "tomatoes, cheese"
  end

  test "filtering by total time only" do
    visit recipes_url
    
    # Should see the time filter form
    assert_selector "input[name='max_time']"
    assert_selector "label", text: "Maximum time (minutes)"
    
    # Filter for recipes 25 minutes or less
    fill_in "max_time", with: "25"
    click_button "Find Recipes"
    
    # Should see results count
    assert_text "Found"
    assert_text "matching recipes"
    
    # All displayed recipes should show total time ≤ 25 minutes
    # (Note: this is a basic check - the actual filtering logic is tested in unit tests)
    assert_text "min"
  end

  test "combining ingredient and time filters" do
    visit recipes_url
    
    # Search with both filters
    fill_in "ingredients", with: "eggs"
    fill_in "max_time", with: "30"
    click_button "Find Recipes"
    
    # Should preserve both values in form
    assert_field "ingredients", with: "eggs"
    assert_field "max_time", with: "30"
    
    # Should show results
    assert_text "Found"
    assert_text "matching recipes"
  end

  test "clearing filters shows all recipes" do
    visit recipes_url
    
    # Apply filters
    fill_in "ingredients", with: "eggs"
    fill_in "max_time", with: "30"
    click_button "Find Recipes"
    
    # Should see "Show All Recipes" link
    assert_link "Show All Recipes"
    
    # Click to clear filters
    click_link "Show All Recipes"
    
    # Should show all recipes without filter message
    assert_no_text "Found"
    assert_no_text "matching recipes"
  end

  test "time filter form has proper attributes" do
    visit recipes_url
    
    # Check time input has proper attributes
    time_input = find("input[name='max_time']")
    assert_equal "number", time_input[:type]
    assert_equal "1", time_input[:min]
    assert_equal "1", time_input[:step]
    assert_equal "e.g., 30, 60, 120", time_input[:placeholder]
  end

  test "should show recipe details" do
    visit recipe_url(@recipe)
    assert_text @recipe.title
    assert_text @recipe.category
    assert_text @recipe.prep_time.to_s
    assert_text @recipe.cook_time.to_s
    assert_text @recipe.total_time.to_s
  end
end
