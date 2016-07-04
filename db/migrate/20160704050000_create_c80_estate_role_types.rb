class CreateC80EstateRoleTypes < ActiveRecord::Migration
  def change
    create_table :c80_estate_role_types, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.string :title
      t.text :desc
      t.timestamps
    end
  end
end