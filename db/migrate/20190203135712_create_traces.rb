class CreateTraces < ActiveRecord::Migration[5.1]
  def change
    create_table :traces do |t|

      t.timestamps
    end
  end
end
