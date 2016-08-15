class AddPowerPriceValueToC80EstateAreas < ActiveRecord::Migration
  def change
    add_column :c80_estate_areas, :power_price_value, :float
  end
end