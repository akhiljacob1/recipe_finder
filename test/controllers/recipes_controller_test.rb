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

  test "should show recipe" do
    get recipe_url(@recipe)
    assert_response :success
  end
end
