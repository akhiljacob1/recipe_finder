# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database with recipes..."

# Check if recipes already exist to make this idempotent
if Recipe.count > 0
  puts "Recipes already exist in database (#{Recipe.count} recipes)"
  puts "Run 'Recipe.destroy_all' first if you want to re-seed"
else
  puts "Importing recipes from dataset..."
  
  service = RecipeImportService.new
  result = service.call
  
  if result
    puts "✅ Successfully imported #{service.imported_count} recipes!"
  else
    puts "❌ Import completed with #{service.failed_count} errors"
    service.errors.each { |error| puts "   Error: #{error}" }
  end
end

puts "Seeding completed!"
