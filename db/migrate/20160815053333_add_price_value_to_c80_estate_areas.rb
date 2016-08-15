# ради оптимизации вставляем в таблицу новый столбец "значение цены".
# также это нам позволит сотрировать в activeadmin таблице по этому значению
# Не забываем, что цена может быть либо указана явно, либо указана цена за площадь,
# а цена за метр рассчитывается
class AddPriceValueToC80EstateAreas < ActiveRecord::Migration
  def change
    add_column :c80_estate_areas, :price_value, :float
  end
end