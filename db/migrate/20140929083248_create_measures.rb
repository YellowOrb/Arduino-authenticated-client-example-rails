class CreateMeasures < ActiveRecord::Migration
  def change
    create_table :measures do |t|
      t.float :temperature

      t.timestamps
    end
  end
end
