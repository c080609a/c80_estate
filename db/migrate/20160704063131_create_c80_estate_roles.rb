class CreateC80EstateRoles < ActiveRecord::Migration
  def change
    create_table :c80_estate_roles, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.references :role_type, index: true
      t.string :owner_type
      t.references :owner, index: true
      t.timestamps
    end
  end
end