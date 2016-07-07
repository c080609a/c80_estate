class CreateC80EstateAreas < ActiveRecord::Migration
  def change
    create_table :c80_estate_areas, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.string :title
      t.text :desc
      t.references :property, index: true
      t.references :atype, index: true
      t.string :owner_type
      t.references :owner, index: true
      t.string :assigned_person_type
      t.references :assigned_person, index: true
      t.timestamps
    end
  end
end