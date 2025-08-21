require "application_system_test_case"

class RecipesTest < ApplicationSystemTestCase
  setup do
    @recipe = recipes(:pancakes)
  end

  test "visiting the index" do
    visit recipes_url
    assert_selector "h1", text: "Recipes"
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
    assert_text "Showing recipes that match: eggs, flour"
    assert_text "Found 3 matching recipes"
    
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
    assert_text "Showing recipes that match: garlic"
    assert_text "Creamy Tomato Soup"  # has garlic
    assert_text "Quick Chicken Stir Fry"  # has garlic
  end

  test "searching with no matches" do
    visit recipes_url
    
    fill_in "ingredients", with: "quinoa"
    click_button "Find Recipes"
    
    # Should see search query but no results
    assert_text "Showing recipes that match: quinoa"
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
    assert_text "Showing recipes that match: eggs"
    
    # Click "Show All Recipes" link
    click_link "Show All Recipes"
    
    # Should see all recipes again
    assert_no_text "Showing recipes that match"
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

  test "should create recipe" do
    visit recipes_url
    click_on "New recipe"

    fill_in "Author", with: @recipe.author
    fill_in "Category", with: @recipe.category
    fill_in "Cook time", with: @recipe.cook_time
    fill_in "Image url", with: @recipe.image_url
    fill_in "Prep time", with: @recipe.prep_time
    fill_in "Ratings", with: @recipe.ratings
    fill_in "Title", with: @recipe.title
    click_on "Create Recipe"

    assert_text "Recipe was successfully created"
    click_on "Back"
  end

  test "should update Recipe" do
    visit recipe_url(@recipe)
    click_on "Edit this recipe", match: :first

    fill_in "Author", with: @recipe.author
    fill_in "Category", with: @recipe.category
    fill_in "Cook time", with: @recipe.cook_time
    fill_in "Image url", with: @recipe.image_url
    fill_in "Prep time", with: @recipe.prep_time
    fill_in "Ratings", with: @recipe.ratings
    fill_in "Title", with: @recipe.title
    click_on "Update Recipe"

    assert_text "Recipe was successfully updated"
    click_on "Back"
  end

  test "should destroy Recipe" do
    visit recipe_url(@recipe)
    click_on "Destroy this recipe", match: :first

    assert_text "Recipe was successfully destroyed"
  end
end
