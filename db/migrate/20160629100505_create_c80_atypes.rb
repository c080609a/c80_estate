class CreateC80Atypes < ActiveRecord::Migration
  def change
    create_table :c80_estate_atypes, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.string :title
      t.string :slug

      t.timestamps null: false
    end
  end
end
