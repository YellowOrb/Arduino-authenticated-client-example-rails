class AddProbeRefToMeasures < ActiveRecord::Migration
  def change
    add_reference :measures, :user, index: true
  end
end
