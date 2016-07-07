class CreateC80EstateProperties < ActiveRecord::Migration
  def change
    create_table :c80_estate_properties, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.string :title
      t.text :desc
      t.string :address
      t.string :latitude
      t.string :longitude
      t.string :owner_type
      t.references :owner, index: true
      # t.references :atype, index: true
      t.string :assigned_person_type
      t.references :assigned_person, index: true
      t.timestamps
    end
  end
end