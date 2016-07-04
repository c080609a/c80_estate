class CreateC80EstateAtphotos < ActiveRecord::Migration
  def change
    create_table :c80_estate_atphotos, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.string :image
      t.references :atype, index: true
      t.timestamps null: false
    end
  end
end
