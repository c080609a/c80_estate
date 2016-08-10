module C80Estate
  class Area < ActiveRecord::Base
    belongs_to :property
    belongs_to :atype
    belongs_to :owner, :polymorphic => true
    belongs_to :assigned_person, :polymorphic => true
    has_many :item_props, :dependent => :destroy
    accepts_nested_attributes_for :item_props,
                                  :reject_if => lambda { |attributes|
                                    # puts "attributes:: #{attributes}"
                                    # attributes:: {"value"=>"", "prop_name_id"=>""}
                                    !attributes.present? || \
                                  !attributes[:value].present? || \
                                  !attributes[:prop_name_id].present?
                                  },
                                  :allow_destroy => true
    has_many :aphotos, :dependent => :destroy # одна или несколько фоток
    accepts_nested_attributes_for :aphotos,
                                  :reject_if => lambda { |attributes|
                                    !attributes.present?
                                  },
                                  :allow_destroy => true
    has_many :comments, :dependent => :destroy # площадь можно прокомментировать
    has_and_belongs_to_many :astatuses, # единственный статус: либо занята, либо свободна
                            :join_table => 'c80_estate_areas_astatuses'

    has_many :sevents, :dependent => :destroy

    validates :property, :presence => true
    validates :atype, :presence => true
    validate :has_astatus?

    after_create :create_initial_sevent
    after_update :check_and_remove_item_props, :if => :atype_id_changed?
    after_update :check_and_generate_sevent

    def self.all_areas
      self.all
    end

    def self.free_areas
      self.joins(:astatuses).where(:c80_estate_astatuses => {tag: 'free'})
    end

    # def self.my_areas
    #   self.joins(:property)
    #       .where(:c80_estate_properties => {assigned_person_id: current_admin_user.id})
    # end

    # scope :my_areas, lambda { |t| t.joins(:property).where(:c80_estate_properties => {assigned_person_id: current_admin_user.id}) }

    # посчитает кол-во свободных метров
    def self.free_areas_sq
      Rails.logger.debug "<Area.free_areas_sq>"
      sum = 0.0
      self.free_areas.each do |area|
        # area_prop_square = area.item_props.where(:prop_name_id => 9)
        area_prop_square = area.square_value
        sum += area_prop_square
      end
      Rails.logger.debug "<Area.free_areas_sq> sum = #{sum}"
      sum
    end

    def self.busy_areas
      self.joins(:astatuses).where(:c80_estate_astatuses => {tag: 'busy'})
    end

    # посчитает кол-во занятых метров
    def self.busy_areas_sq
      sum = 0.0
      self.busy_areas.each do |area|
        area_prop_square = area.item_props.where(:prop_name_id => 9)
        if area_prop_square.present?
          sum += area_prop_square.first.value.to_f
        end
      end
      sum
    end

    def self.all_areas_sq
      sum = 0.0
      self.all.each do |area|
        area_prop_square = area.item_props.where(:prop_name_id => 9)
        if area_prop_square.present?
          sum += area_prop_square.first.value.to_f
        end
      end
      sum
    end

    def self.where_price_range(range)
      self.joins(:item_props)
          .where(c80_estate_item_props: {prop_name_id: 1})
          .where('c80_estate_item_props.value > ?', range.split(',')[0].to_f-1)
          .where('c80_estate_item_props.value < ?', range.split(',')[1].to_f+1)
    end

    def self.where_square_range(range)
      C80Estate::Area.joins(:item_props)
          .where(c80_estate_item_props: {prop_name_id: 9})
          .where('c80_estate_item_props.value > ?', range.split(',')[0].to_f-1)
          .where('c80_estate_item_props.value < ?', range.split(',')[1].to_f+1)
    end

    def self.where_oenter(v)
      # Rails.logger.debug "\t\t [2]: v = #{v}"
      r = C80Estate::Area.joins(:item_props)
              .where(c80_estate_item_props: {prop_name_id: 8})
      if v.to_i == 11
        r = r.where(c80_estate_item_props: {value: 1})
      else
        r = r.where.not(c80_estate_item_props: {value: 1})
      end
      r
    end

    def self.where_floor(v)
      # Rails.logger.debug "\t\t [2]: v = #{v}"
      C80Estate::Area.joins(:item_props)
          .where(c80_estate_item_props: {prop_name_id: 5})
          .where(c80_estate_item_props: {value: v})
    end

    def self.where_assigned_person_id(id)
      # Rails.logger.debug "\t\t [2]: v = #{v}"
      C80Estate::Area.joins(:property)
          .where(:c80_estate_properties => {assigned_person_id: id})
    end

    def self.import_excel(file)

      Rails.logger.debug "------------------------------------------------------------- self.import [BEGIN] "

      import_result = ''
      spreadsheet = open_spreadsheet(file)
      header = spreadsheet.row(1)

      # Rails.logger.debug(header)
      # ["title", "atype", "square", "price", "status"]

      (2..spreadsheet.last_row).each do |i|

        row = Hash[[header, spreadsheet.row(i)].transpose]

        Rails.logger.debug("---------- #{row} -----------")
        # {"title"=>"С2-1.18", "atype"=>"Торговое помещение", "square"=>"0", "price"=>800.0, "status"=>"Занята"}

        #   area_where = Area.where(:slug => row["ID"])
        #   if area_where.count > 0
        #
        #     area = Area.where(:slug => row["ID"]).first
        #     puts "--- Обновляем данные для #{area.id}, #{area.slug}: "
        #     puts "--- Хотим вставить данные: " + row.to_hash.to_s
        #     area.price = row["Цена"]
        #     area.space = row["Площадь"]
        #     area.save
        #     puts "."
        #
        #   else
        #     s = "В базе не найден павильон: #{row.to_hash}"
        #     import_result += s + "\n"
        #     puts s
        #
        #   end
        #
        #

        area = C80Estate::Area.create!({
                                           title: row['title'],
                                           property_id: row['property_id'].to_i,
                                           atype_id: row['atype_id'].to_i,
                                           owner_type: 'AdminUser',
                                           owner_id: 2,
                                           assigned_person_type: 'AdminUser',
                                           assigned_person_id: 2
                                       })

        C80Estate::ItemProp.create!([
                                        {value: row['price'].to_f, area_id: area.id, prop_name_id: 1},
                                        {value: row['square'].to_f, area_id: area.id, prop_name_id: 9},
                                    ])

        area.astatuses << C80Estate::Astatus.find(row['astatus'].to_i)
        area.save

      end

      puts "------------------------------------------------------------- self.import [END] "
      import_result

    end

    def self.where_atype(atype_id)
      self.where(:atype_id => atype_id)
    end

    # Не отображать "чужие" занятые площади (для менеждеров) (задача №1748)
    def self.all_except_busy_alien(admin_user)
      if admin_user.can_view_statistics?
        # админам покажем всё
        self.all
      else

        # http://stackoverflow.com/questions/9540801/combine-two-activerecordrelation-objects
        # двумя независимыми запросами получим мои площади и немои свободные площади, сложим их, и отдадим

=begin
        # ВАРИАНТ 1

        # извлечём немои свободные площади
        # этот код я написал, смотря на уже существующий where_assigned_person_id
        not_my_free_areas = self.free_areas
                      .joins(:property)
                      .where.not(:c80_estate_properties => {assigned_person_id: admin_user.id})

        # извлечём все мои площади
        all_my_areas = self.joins(:property)
                           .where(:c80_estate_properties => {assigned_person_id: admin_user.id})

        # это вернёт только то, что находится в ПЕРЕСЕЧЕНИИ результатов, а нужен union
        not_my_free_areas.merge(all_my_areas)
=end

=begin
        # ВАРИАНТ 2
        # http://stackoverflow.com/a/28358592
        # User.where(
        #     User.arel_table[:first_name].eq('Tobias').or(
        #         User.arel_table[:last_name].eq('Fünke')
        #     )
        # )
=end

=begin
        # ВАРИАНТ 3
        # http://stackoverflow.com/a/31528499
        # first_name_relation = User.where(:first_name => 'Tobias') # ActiveRecord::Relation
        # last_name_relation  = User.where(:last_name  => 'Fünke') # ActiveRecord::Relation
        #
        # all_name_relations = User.none
        # first_name_relation.each do |ar|
        #   all_name_relations.new(ar)
        # end
        # last_name_relation.each do |ar|
        #   all_name_relations.new(ar)
        # end
=end

        # попробуем 3-й вариант
        not_my_free_areas = self.free_areas
                                .joins(:property)
                                .where.not(:c80_estate_properties => {assigned_person_id: admin_user.id})

        all_my_areas = self.joins(:property)
                           .where(:c80_estate_properties => {assigned_person_id: admin_user.id})

        all_my_areas.union(not_my_free_areas)

      end
    end

    def has_astatus?
      errors.add_to_base 'Укажите статус площади' if self.astatuses.blank?
    end

    # --------

    def atype_title
      atype.title
    end

    def property_title
      property.title
    end

    def astatus_title
      astatuses.first.title
    end

    def astatus_id
      astatuses.first.id
    end

    def astatus_tag
      astatuses.first.tag
    end

    # --------

    def is_free?
      astatus_tag == 'free'
    end

    def is_busy?
      astatus_tag == 'busy'
    end

    def assigned_person_title
      res = '-'
      if property.assigned_person.present?
        res = property.assigned_person.email
      end
      res
    end

    def owner_id
      res = -1
      if owner.present?
        res = owner.id
      end
      res
    end

    def last_updater
      sevents.last.auser.email
    end

    # выдать цену за м.кв. в месяц
    # TODO_MY:: добавить модели Area столбец price_value и before_update метод, который высчитывал бы значение
    def price_value

      res = 0.0
      mark_use_usual_price = false

      # если указана "цена за площадь",
      # то цену за м кв. в месяц высчитываем
      pa = item_props.where(:prop_name_id => 14)
      if pa.count > 0
        pa_val = pa.first.value.to_f

        if pa_val == 0
          # если руками было проставлено 0 - т.е. свойство как бы было удалено, выключено
          mark_use_usual_price = true
        else
          if square_value != 0
            # результат получаем только тогда, когда указана площадь и когда указана цена за площадь
            res = pa_val / square_value
          else
            # если не указана площадь - то берём обычную цену
            mark_use_usual_price = true
          end
        end
      else
        mark_use_usual_price = true
      end

      if mark_use_usual_price
        p = item_props.where(:prop_name_id => 1)
        if p.count > 0
          res = p.first.value.to_f
        end
      end

      res
    end

    # TODO_MY:: добавить модели Area столбец square_value и before_update метод, который высчитывал бы значение
    def square_value
      res = 0.0
      p = item_props.where(:prop_name_id => 9)
      if p.count > 0
        res = p.first.value.to_f
      end
      Rails.logger.debug "<Area.square_value> res = #{res}"
      res
    end

    # TODO_MY:: добавить модели Area столбец power_price_value и before_update метод, который высчитывал бы значение
    def power_price_value
      price_value * 1.0 * square_value
    end

    def main_image_url
      url = "no_thumb_#{atype.id}.jpg"

      if aphotos.count > 0
        url = aphotos.first.image.thumb512
      end
      url
    end

    # вернёт true, если вручную указана цена за всю площадь
    def is_locked_area_price?
      res = false
      pa = item_props.where(:prop_name_id => 14)
      if pa.count > 0
        pa_val = pa.first.value.to_f
        if pa_val > 0
          res = true
        end
      end
      res
    end

    ransacker :item_prop_price_val,
              formatter: proc { |price_range| # 10,156
                results = C80Estate::Area.where_price_range(price_range).map(&:id)
                results = results.present? ? results : nil
              }, splat_params: true do |parent|
      parent.table[:id]
    end

    ransacker :item_prop_square_val,
              formatter: proc { |square_range|
                results = C80Estate::Area.where_square_range(square_range).map(&:id)
                results = results.present? ? results : nil
              }, splat_params: true do |parent|
      parent.table[:id]
    end

    ransacker :item_prop_floor_val,
              formatter: proc { |v|
                results = C80Estate::Area.where_floor(v).map(&:id)
                results = results.present? ? results : nil
              }, splat_params: true do |parent|
      parent.table[:id]
    end

    ransacker :assigned_person_id,
              formatter: proc { |v|
                results = C80Estate::Area.where_assigned_person_id(v).map(&:id)
                results = results.present? ? results : nil
              }, splat_params: true do |parent|
      parent.table[:id]
    end

    ransacker :item_prop_oenter,
              formatter: proc { |option|
                # Неважно: -1
                # Да: 1
                # Нет: 0
                Rails.logger.debug "\t\t [1]: option = #{option}"

                if option.to_i == 10 || option.to_i == 11
                  results = C80Estate::Area.where_oenter(option).map(&:id)
                end

                results = results.present? ? results : nil
              }, splat_params: true do |parent|
      parent.table[:id]
    end

    protected

    # при создании площади генерится начальное событие
    def create_initial_sevent
      Rails.logger.debug "<Area.create_initial_sevent> self.astatuses.count = #{self.astatuses.count}"

      # [**]
      if self.astatuses.count > 0
        Rails.logger.debug "<Area.create_initial_sevent> aga: self.astatuses.first.title = #{self.astatuses.first.title}"

        s = Sevent.create!({
                               area_id: self.id,
                               atype_id: self.atype_id,
                               property_id: self.property_id,
                               astatus_id: self.astatus_id,
                               auser_id: self.owner_id, # инициатор события - создатель Площади
                               auser_type: 'AdminUser',
                               created_at: self.created_at
                           })

        pparams = {
            atype_id: nil,
            property_id: self.property_id,
            sevent_id: s.id,
            created_at: self.created_at
        }

        # генерим запись с общими данными
        # связываем её с Sevent
        # чтобы можно было удалить как dependent => destroy
        Pstat.create!(pparams)

      end

    end

    def check_and_generate_sevent

      # находим последнее известное событие
      # фиксируем его статус
      last_known_sevent = ""
      if self.sevents.count > 0
        last_known_sevent = self.sevents.last.astatus.tag
      end

      # если статус этого события отличен
      # от нового статуса - генерим события
      Rails.logger.debug "<Area.check_and_generate_sevent> last_known_sevent = #{last_known_sevent}, self.astatuses.first.tag = #{self.astatuses.first.tag}"

      if last_known_sevent != self.astatuses.first.tag
        Rails.logger.debug "<Area.check_and_generate_sevent> aga"
        sparams = {
            area_id: self.id,
            atype_id: self.atype_id,
            property_id: self.property_id,
            astatus_id: self.astatus_id,
            auser_id: self.owner_id, # инициатор события - редактор Площади
            auser_type: 'AdminUser'
        }

        # если неизвестен статус последнего события,
        # значит событий изменения статуса площади ещё не было
        # значит нужно создать первое событие и дату его создания
        # приравнять дате создания площади [*]
        # такая штука случается, когда заполняем данными из seed файла,
        # и при создании не получилось фишка с передачей :astatus_ids => [1] в create!({..})
        # по-этому и появился этот код. Также по теме код из [**]
        if last_known_sevent == ''
          sparams[:created_at] = self.created_at
        end

        s = Sevent.create!(sparams)

        pparams = {
            atype_id: nil,
            property_id: self.property_id,
            sevent_id: s.id
        }

        # см [*]
        if last_known_sevent == ''
          pparams[:created_at] = self.created_at
        end

        # генерим запись с общими данными
        # связываем её с Sevent
        # чтобы можно было удалить как dependent => destroy
        Pstat.create!(pparams)

      end

    end

    def check_and_remove_item_props
      Rails.logger.debug '<check_and_remove_item_props> BEGIN'

      clean_unrelated_item_props
      clean_duplicated_item_props

      Rails.logger.debug '<check_and_remove_item_props> END'
    end

    private

    def self.open_spreadsheet(file)
      case File.extname(file.original_filename)
        when ".xls" then
          Roo::Excel.new(file.path)
        when ".xlsx" then
          Roo::Excelx.new(file.path)
        else
          raise "Неизвестный формат файла: #{file.original_filename}"
      end
    end

    def clean_unrelated_item_props
      # item_props = [ {area,prop_name} ]
      # item_props.delete_all

      # на этом этапе в запись уже помещены данные о новых свойствах
      # тут необходимо пройтись по свойствам, выбрать те, которые не присущи новому типу,
      # и удалить их

      # находим PropNames присущие Типу
      atype_prop_names = Atype.get_propnames(atype.id)
      # [ {"id"=>37, "title"=>"Артикул", "is_excluded_from_filtering"=>1, "uom_title"=>nil},... ]

      # составляем массив айдишников
      atype_prop_names_ids = []
      atype_prop_names.each do |prop_name|
        # Rails.logger.debug "<clean_unrelated_item_props> prop_name = #{prop_name}"
        # begin
        atype_prop_names_ids << prop_name['id'].to_i
        # rescue => e
        # Rails.logger.debug "<clean_unrelated_item_props> [ERROR]: #{e}"
        # end

      end
      # Rails.logger.debug "<clean_unrelated_item_props> atype_prop_names_ids = #{atype_prop_names_ids}"

      # теперь обходим Item Props
      # если айдишника PropName очередного ItemProp нет в списке PropNames присущих Типу,
      # удаляем это ItemProp
      item_props.each do |item_prop|
        # Rails.logger.debug "<clean_unrelated_item_props> item_prop.prop_name.id = #{item_prop.prop_name.id}"
        unless atype_prop_names_ids.include?(item_prop.prop_name.id.to_i)
          Rails.logger.debug "<clean_unrelated_item_props> Удаляем '#{item_prop.prop_name.title}' из площади типа '#{atype.title}'."
          item_prop.destroy
        end
      end

    end

    def clean_duplicated_item_props
      # удаляем дубликаты
      Rails.logger.debug "<clean_dublicated_item_props>"
      item_props.each do |item_prop|
        duplicates = item_props
                         .where(area_id: item_prop.area_id)
                         .where(prop_name_id: item_prop.prop_name_id)
                         .where.not(id: item_prop.id)
        Rails.logger.debug "<clean_dublicated_item_props> #{item_prop.prop_name.title}: dublicates.count = #{duplicates.count}"

        if duplicates.count > 0
          Rails.logger.debug "<clean_dublicated_item_props> delete '#{item_prop.prop_name.title}', val: #{item_prop.value}"
          duplicates.delete_all
        end
      end
    end

  end
end