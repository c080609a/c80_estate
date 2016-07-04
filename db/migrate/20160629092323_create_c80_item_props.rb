class CreateC80ItemProps < ActiveRecord::Migration
  def change
    create_table :c80_estate_item_props, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.string :value
      t.references :area, index: true
      t.references :property, index: true
      t.references :prop_name, index: true

      t.timestamps null: false
    end
    # add_foreign_key :c80_item_props, :areas
    # add_foreign_key :c80_item_props, :prop_names
  end
end
