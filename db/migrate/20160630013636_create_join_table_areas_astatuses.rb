class CreateJoinTableAreasAstatuses < ActiveRecord::Migration
  def change
    create_table :c80_estate_areas_astatuses, :id => false do |t|
      t.integer :area_id, :null => false
      t.integer :astatus_id, :null => false
    end

    # Add table index
    add_index :c80_estate_areas_astatuses, [:astatus_id, :area_id], :unique => true, :name => 'my_index'

  end
end
