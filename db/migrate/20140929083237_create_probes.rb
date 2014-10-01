class CreateProbes < ActiveRecord::Migration
  def change
    create_table :probes do |t|
      t.string :name
      t.string :secret

      t.timestamps
    end
  end
end
