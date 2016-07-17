class CreateC80EstatePstats < ActiveRecord::Migration
  def change
    create_table :c80_estate_pstats, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.references :property, index: true
      t.references :atype, index: true
      t.references :sevent, index: true
      t.references :parent, index: true
      t.integer :free_areas
      t.integer :busy_areas
      t.integer :coef_busy
      t.integer :free_areas_sq
      t.integer :busy_areas_sq
      t.integer :coef_busy_sq
      t.timestamps
    end
  end
end