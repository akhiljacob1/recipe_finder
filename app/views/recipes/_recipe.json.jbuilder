json.extract! recipe, :id, :title, :cook_time, :prep_time, :ratings, :category, :author, :image_url, :created_at, :updated_at
json.url recipe_url(recipe, format: :json)
