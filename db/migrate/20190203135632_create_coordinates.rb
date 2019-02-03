class CreateCoordinates < ActiveRecord::Migration[5.1]
  def change
    create_table :coordinates do |t|
      t.integer :trace_id
      t.decimal :lat, :precision=>10, :scale=>8
      t.decimal :lon, :precision=>11, :scale=>8

      t.timestamps
    end
  end
end
