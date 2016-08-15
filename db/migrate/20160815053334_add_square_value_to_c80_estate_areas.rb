# ради оптимизации вставляем в таблицу новый столбец "значение площади".
# также это нам позволит сотрировать в activeadmin таблице по этому значению
class AddSquareValueToC80EstateAreas < ActiveRecord::Migration
  def change
    add_column :c80_estate_areas, :square_value, :float
  end
end