class CreateC80EstateAphotos < ActiveRecord::Migration
  def change
    create_table :c80_estate_aphotos, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.string :image
      t.references :area, index: true
      t.timestamps null: false
    end
  end
end
