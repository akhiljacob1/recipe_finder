require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recipe = recipes(:pancakes)
  end

  test "should get index" do
    get recipes_url
    assert_response :success
  end

  test "should get index with search parameters" do
    get recipes_url, params: { ingredients: "eggs, flour" }
    assert_response :success
  end

  test "index view should display search form" do
    get recipes_url
    assert_response :success
    
    # Check for search form elements
    assert_select "form[action=?]", recipes_path
    assert_select "input[name='ingredients']"
    assert_select "input[type='submit']"
  end

  test "should get new" do
    get new_recipe_url
    assert_response :success
  end

  test "should create recipe" do
    assert_difference("Recipe.count") do
      post recipes_url, params: { recipe: { author: @recipe.author, category: @recipe.category, cook_time: @recipe.cook_time, image_url: @recipe.image_url, prep_time: @recipe.prep_time, ratings: @recipe.ratings, title: @recipe.title } }
    end

    assert_redirected_to recipe_url(Recipe.last)
  end

  test "should show recipe" do
    get recipe_url(@recipe)
    assert_response :success
  end

  test "should get edit" do
    get edit_recipe_url(@recipe)
    assert_response :success
  end

  test "should update recipe" do
    patch recipe_url(@recipe), params: { recipe: { author: @recipe.author, category: @recipe.category, cook_time: @recipe.cook_time, image_url: @recipe.image_url, prep_time: @recipe.prep_time, ratings: @recipe.ratings, title: @recipe.title } }
    assert_redirected_to recipe_url(@recipe)
  end

  test "should destroy recipe" do
    assert_difference("Recipe.count", -1) do
      delete recipe_url(@recipe)
    end

    assert_redirected_to recipes_url
  end
end
