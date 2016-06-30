class CreateC80EstateAstatuses < ActiveRecord::Migration
  def change
    create_table :c80_estate_astatuses, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.string :tag
      t.string :title
      t.timestamps null: false
    end
  end
end
