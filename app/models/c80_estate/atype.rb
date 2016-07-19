require "babosa"

module C80Estate

  class Atype < ActiveRecord::Base

    # http://stackoverflow.com/questions/9382708/rails-3-has-many-changed
    has_and_belongs_to_many :prop_names,
                            :join_table => 'c80_estate_atypes_prop_names',
                            :after_add => :after_add_prop_names,
                            :after_remove => :after_remove_prop_names

    has_many :areas, :dependent => :destroy
    # has_many :properties, :dependent => :destroy
    has_many :atphotos, :dependent => :destroy   # одна или несколько фоток

    has_many :sevents, :dependent => :nullify

    has_many :pstats, :dependent => :nullify

    extend FriendlyId
    friendly_id :slug_candidates, :use => :slugged

    def slug_candidates
      [:title] + Array.new(6) {|index| [:title, index+2]}
    end

    def normalize_friendly_id(input)
      input.to_s.to_slug.normalize(transliterations: :russian).to_s
    end

    # • этот метод дёргает только StrsubcatSweeper
    # • после вызова метода - значение сбрасывается в false
    def prop_names_changed?
      res = @mark_prop_names_changed
      @mark_prop_names_changed = false
      res
    end

    def get_list_removed_props
      @list_removed_props = [] unless @list_removed_props.present?
      res = @list_removed_props
      @list_removed_props = []
      res
    end

    # выдать все характеристики, присущие данной категории, вместе с единицами измерений
    def self.get_propnames(atype_id)

=begin
          >> stdh_get_atype_propnames(1)
      <stdh_get_atype_propnames> BEGIN
         (0.2ms)
          SELECT
            `prop_names`.`id`,
            `prop_names`.`title`,
            `prop_names`.`is_excluded_from_filtering`,
            `uoms`.`title` as uom_title
          FROM `prop_names`
            INNER JOIN `prop_names_atypes` ON `prop_names`.`id` = `prop_names_atypes`.`prop_name_id`
            LEFT OUTER JOIN uoms ON uoms.id = prop_names.uom_id
          WHERE `prop_names_atypes`.`atype_id` = 1;

      {"id"=>18, "title"=>"Цена за шт.", "is_excluded_from_filtering"=>1, "uom_title"=>"руб"}
      {"id"=>19, "title"=>"Цена за шт. (старая)", "is_excluded_from_filtering"=>1, "uom_title"=>"руб"}
      {"id"=>20, "title"=>"Цена за м²", "is_excluded_from_filtering"=>1, "uom_title"=>"руб"}
      {"id"=>21, "title"=>"Цена за м² (старая)", "is_excluded_from_filtering"=>1, "uom_title"=>"руб"}
      {"id"=>23, "title"=>"Размер", "is_excluded_from_filtering"=>0, "uom_title"=>nil}
      {"id"=>24, "title"=>"Страна", "is_excluded_from_filtering"=>0, "uom_title"=>nil}
      {"id"=>25, "title"=>"Прочность на сжатие", "is_excluded_from_filtering"=>0, "uom_title"=>"кгс/см²"}
      {"id"=>26, "title"=>"Коэффициент теплопроводности", "is_excluded_from_filtering"=>0, "uom_title"=>"Вт/м×°C"}
      {"id"=>27, "title"=>"Марка по морозостойкости", "is_excluded_from_filtering"=>0, "uom_title"=>nil}
      {"id"=>28, "title"=>"Водопоглощение", "is_excluded_from_filtering"=>0, "uom_title"=>"%"}
      {"id"=>29, "title"=>"Цвет", "is_excluded_from_filtering"=>0, "uom_title"=>nil}
      {"id"=>30, "title"=>"Пустотность", "is_excluded_from_filtering"=>0, "uom_title"=>nil}
      {"id"=>31, "title"=>"Формовка", "is_excluded_from_filtering"=>0, "uom_title"=>nil}
      {"id"=>32, "title"=>"Поверхность", "is_excluded_from_filtering"=>0, "uom_title"=>nil}
      {"id"=>33, "title"=>"Вес", "is_excluded_from_filtering"=>0, "uom_title"=>nil}
      {"id"=>34, "title"=>"Количество на поддоне", "is_excluded_from_filtering"=>1, "uom_title"=>"шт"}
      {"id"=>35, "title"=>"Тип кирпича", "is_excluded_from_filtering"=>0, "uom_title"=>nil}
      {"id"=>36, "title"=>"Производитель", "is_excluded_from_filtering"=>0, "uom_title"=>nil}
      {"id"=>37, "title"=>"Артикул", "is_excluded_from_filtering"=>1, "uom_title"=>nil}
      {"id"=>38, "title"=>"Формат", "is_excluded_from_filtering"=>0, "uom_title"=>nil}
      <stdh_get_atype_propnames> END
=end

      Rails.logger.debug "<Atype.get_propnames> BEGIN"
      sql = "
    SELECT
      `c80_estate_prop_names`.`id`,
      `c80_estate_prop_names`.`title`,
      `c80_estate_prop_names`.`is_excluded_from_filtering`,
      `c80_estate_uoms`.`title` as uom_title
    FROM `c80_estate_prop_names`
      INNER JOIN `c80_estate_atypes_prop_names` ON `c80_estate_prop_names`.`id` = `c80_estate_atypes_prop_names`.`prop_name_id`
      LEFT OUTER JOIN `c80_estate_uoms` ON `c80_estate_uoms`.`id` = `c80_estate_prop_names`.`uom_id`
    WHERE `c80_estate_atypes_prop_names`.`atype_id` = #{atype_id};
    "

      result = []
      rows = ActiveRecord::Base.connection.execute(sql)
      rows.each(:as => :hash) do |row|
        result << row
      end

      Rails.logger.debug "<Atype.get_propnames> END"
      result

    end
    
    private

    # • Два метода after_add_prop_names и after_remove_prop_names
    # слушают изменения prop_names, и, при их наличии,
    # выставляют флаг mark_prop_names_changed в true.
    # • Этот флаг вертает обратно в false
    # метод after_update "чистильщика" StrsubcatSweeper.

    def after_add_prop_names(prop_name)
      unless new_record?
        puts "<Strsubcat.after_add_prop_names>: #{prop_name.title}"
        @mark_prop_names_changed = true
      end
    end

    def after_remove_prop_names(prop_name)
      puts "<Strsubcat.after_remove_prop_names>: #{prop_name.title}"
      @mark_prop_names_changed = true
      @list_removed_props = [] unless @list_removed_props.present?
      @list_removed_props << prop_name.id
    end

  end


end