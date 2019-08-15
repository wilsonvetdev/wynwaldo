class AddVisitsCountToPhotos < ActiveRecord::Migration[6.0]
  def change
    add_column :photos, :visits_count, :integer, null: false, default: 0
  end
end
