class CreateC80EstatePlogos < ActiveRecord::Migration
  def change
    create_table :c80_estate_plogos, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.string :image
      t.references :property, index: true
      t.timestamps null: false
    end
  end
end
