class CreateC80EstateComments < ActiveRecord::Migration
  def change
    create_table :c80_estate_comments, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.text :content
      t.references :area, index: true
      t.references :property, index: true
      t.string :owner_type
      t.references :owner, index: true
      t.timestamps null: false
    end
  end
end
