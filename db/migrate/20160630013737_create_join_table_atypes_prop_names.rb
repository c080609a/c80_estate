class CreateJoinTableAtypesPropNames < ActiveRecord::Migration
  def change
    create_table :c80_estate_atypes_prop_names, :id => false do |t|
      t.integer :atype_id, :null => false
      t.integer :prop_name_id, :null => false
    end

    # Add table index
    add_index :c80_estate_atypes_prop_names, [:prop_name_id, :atype_id], :unique => true, :name => 'my_index2'

  end
end
