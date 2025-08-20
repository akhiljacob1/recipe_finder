class RecipeImportService
  attr_reader :file_path, :imported_count, :failed_count, :errors

  def initialize(file_path = nil)
    @file_path = file_path || Rails.root.join('recipes-en.json')
    @imported_count = 0
    @failed_count = 0
    @errors = []
  end

  def call(count: nil)
    validate_file!
    
    recipes_data = load_recipes_data
    recipes_to_import = count ? recipes_data.first(count) : recipes_data
    
    log_dataset_info(recipes_data, count)
    
    import_recipes(recipes_to_import)
    
    log_import_summary
    
    success?
  end

  def success?
    @failed_count == 0
  end

  private

  def validate_file!
    unless File.exist?(@file_path)
      raise "Recipe file not found at #{@file_path}"
    end
  end

  def load_recipes_data
    puts "Reading recipes from #{@file_path}..."
    JSON.parse(File.read(@file_path))
  rescue JSON::ParserError => e
    raise "Invalid JSON format: #{e.message}"
  end

  def log_dataset_info(recipes_data, count)
    puts "Found #{recipes_data.length} total recipes in dataset"
    if count
      puts "Importing first #{count} recipes..."
    else
      puts "Importing all #{recipes_data.length} recipes..."
    end
  end

  def import_recipes(recipes_to_import)
    recipes_to_import.each_with_index do |recipe_data, index|
      import_single_recipe(recipe_data, index)
    end
  end

  def import_single_recipe(recipe_data, index)
    recipe = Recipe.create!(
      title: recipe_data['title'],
      cook_time: recipe_data['cook_time'],
      prep_time: recipe_data['prep_time'],
      ratings: recipe_data['ratings'],
      category: recipe_data['category'],
      author: recipe_data['author'],
      image_url: recipe_data['image'],
      ingredients: recipe_data['ingredients']
    )
    
    @imported_count += 1
    puts "#{index + 1}. Imported: #{recipe.title}"
    
  rescue StandardError => e
    @failed_count += 1
    error_message = "#{index + 1}. Failed to import recipe: #{recipe_data['title']} - Error: #{e.message}"
    @errors << error_message
    Rails.logger.error error_message
  end

  def log_import_summary
    puts "\nImport completed!"
    puts "Successfully imported: #{@imported_count} recipes"
    puts "Failed imports: #{@failed_count} recipes" if @failed_count > 0
    puts "Total recipes in database: #{Recipe.count}"
  end
end
