class AddLastEditorToC80EstateAreas < ActiveRecord::Migration
  def change
    add_reference :c80_estate_areas, :last_updater, index: true
    add_column :c80_estate_areas, :last_updater_type, :string
  end
end