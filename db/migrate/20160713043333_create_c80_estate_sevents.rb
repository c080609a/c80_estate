class CreateC80EstateSevents < ActiveRecord::Migration
  def change
    create_table :c80_estate_sevents, :options => 'COLLATE=utf8_unicode_ci' do |t|
      t.references :area, index: true
      t.references :atype, index: true
      t.references :property, index: true
      t.references :astatus, index: true
      t.references :auser, index: true
      t.string :auser_type
      t.timestamps
    end
  end
end