class AddDistanceToCoordinates < ActiveRecord::Migration[5.2]
  def change
      add_column :coordinates, :distance, :integer
  end
end
