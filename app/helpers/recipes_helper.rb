module RecipesHelper
  def ingredient_matches_search?(ingredient, search_query)
    return nil if search_query.blank?
    
    search_ingredients = search_query.split(',').map(&:strip).map(&:downcase)
    ingredient_lower = ingredient.downcase
    
    search_ingredients.any? do |search_ingredient|
      ingredient_lower.include?(search_ingredient) || search_ingredient.include?(ingredient_lower)
    end
  end

  def ingredient_highlight_classes(ingredient, search_query)
    is_matching = ingredient_matches_search?(ingredient, search_query)
    
    case is_matching
    when nil
      { background: 'bg-stone-50', dot: 'bg-orange-400' }
    when true
      { background: 'bg-green-100', dot: 'bg-green-400' }
    when false
      { background: 'bg-red-100', dot: 'bg-red-400' }
    end
  end
end
