class AddTotalTimeToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :total_time, :integer
  end
end
