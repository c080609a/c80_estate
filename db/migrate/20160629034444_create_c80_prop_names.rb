class CreateC80PropNames < ActiveRecord::Migration
  def change
    create_table :c80_estate_prop_names, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.string :title
      t.boolean :is_normal_price
      t.boolean :is_excluded_from_filtering
      t.references :uom, index: true
      t.timestamps
    end
    # add_foreign_key :c80_sass_seo_sites, :owners
  end
end