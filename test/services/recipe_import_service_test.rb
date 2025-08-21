require "test_helper"

class RecipeImportServiceTest < ActiveSupport::TestCase
  def setup
    @service = RecipeImportService.new
  end

  test "calculates total_time correctly during import" do
    # Create a temporary JSON file for testing
    test_data = [
      {
        "title" => "Test Recipe",
        "cook_time" => 20,
        "prep_time" => 15,
        "ratings" => 4.5,
        "category" => "Test",
        "author" => "Test Chef",
        "image" => "test.jpg",
        "ingredients" => ["ingredient1", "ingredient2"]
      }
    ]
    
    temp_file = Tempfile.new(['test_recipes', '.json'])
    temp_file.write(test_data.to_json)
    temp_file.close
    
    # Import using our service
    service = RecipeImportService.new(temp_file.path)
    service.call
    
    # Check that total_time was calculated correctly
    recipe = Recipe.find_by(title: "Test Recipe")
    assert_not_nil recipe
    assert_equal 20, recipe.cook_time
    assert_equal 15, recipe.prep_time
    assert_equal 35, recipe.total_time
    
    temp_file.unlink
  end

  test "skips recipes with zero total_time" do
    test_data = [
      {
        "title" => "Zero Times Recipe",
        "cook_time" => 0,
        "prep_time" => 0,
        "ratings" => 4.0,
        "category" => "Test",
        "author" => "Test Chef",
        "image" => "test.jpg",
        "ingredients" => ["ingredient1"]
      }
    ]
    
    temp_file = Tempfile.new(['test_recipes_zero', '.json'])
    temp_file.write(test_data.to_json)
    temp_file.close
    
    service = RecipeImportService.new(temp_file.path)
    service.call
    
    # Recipe should be skipped, not imported
    recipe = Recipe.find_by(title: "Zero Times Recipe")
    assert_nil recipe
    assert_equal 1, service.skipped_count
    assert_equal 0, service.imported_count
    
    temp_file.unlink
  end
end
