class ChangeC80EstatePstatsColumnTypes < ActiveRecord::Migration
  def up
    change_column :c80_estate_pstats, :coef_busy, :float
    change_column :c80_estate_pstats, :free_areas_sq, :float
    change_column :c80_estate_pstats, :busy_areas_sq, :float
    change_column :c80_estate_pstats, :coef_busy_sq, :float
  end

  def down
    change_column :c80_estate_pstats, :coef_busy, :integer
    change_column :c80_estate_pstats, :free_areas_sq, :integer
    change_column :c80_estate_pstats, :busy_areas_sq, :integer
    change_column :c80_estate_pstats, :coef_busy_sq, :integer
  end
end