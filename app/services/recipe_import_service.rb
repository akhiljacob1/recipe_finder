class RecipeImportService
  attr_reader :file_path, :imported_count, :failed_count, :skipped_count, :errors

  def initialize(file_path = nil)
    @file_path = file_path || Rails.root.join('recipes-en.json')
    @imported_count = 0
    @failed_count = 0
    @skipped_count = 0
    @errors = []
  end

  def call
    validate_file!
    
    recipes_data = load_recipes_data
    recipes_to_import = recipes_data
    
    log_dataset_info(recipes_data)
    
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

  def log_dataset_info(recipes_data)
    puts "Found #{recipes_data.length} total recipes in dataset"
    puts "Importing all #{recipes_data.length} recipes..."
  end

  def import_recipes(recipes_to_import)
    recipes_to_import.each_with_index do |recipe_data, index|
      import_single_recipe(recipe_data, index)
    end
  end

  def import_single_recipe(recipe_data, index)
    cook_time = recipe_data['cook_time'] || 0
    prep_time = recipe_data['prep_time'] || 0
    total_time = cook_time + prep_time
    
    # Skip recipes with no time information (data cleaning)
    if total_time <= 0
      @skipped_count += 1
      puts "#{index + 1}. Skipped (no time data): #{recipe_data['title']}"
      return
    end
    
    recipe = Recipe.create!(
      title: recipe_data['title'],
      cook_time: cook_time,
      prep_time: prep_time,
      total_time: total_time,
      ratings: recipe_data['ratings'],
      category: recipe_data['category'],
      author: recipe_data['author'],
      image_url: extract_actual_image_url(recipe_data['image']),
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
    puts "Skipped (no time data): #{@skipped_count} recipes" if @skipped_count > 0
    puts "Failed imports: #{@failed_count} recipes" if @failed_count > 0
    puts "Total recipes in database: #{Recipe.count}"
  end

  def extract_actual_image_url(full_image_url)
    return nil if full_image_url.blank?
    
    # Extract the actual image URL from the full URL
    # Example: https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fimages.media-allrecipes.com%2Fuserphotos%2F50654.jpg
    # Should become: https://images.media-allrecipes.com/userphotos/50654.jpg
    
    begin
      uri = URI(full_image_url)
      if uri.query.present?
        # Parse the query parameters to find the 'url' parameter
        query_params = URI.decode_www_form(uri.query)
        url_param = query_params.find { |key, _| key == 'url' }
        
        if url_param
          # Return the decoded URL parameter
          return CGI.unescape(url_param.last)
        end
      end
      
      # If no 'url' parameter found, return the original URL
      full_image_url
    rescue URI::InvalidURIError
      # If the URL is invalid, return the original
      full_image_url
    end
  end
end
