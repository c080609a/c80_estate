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
    after_update :check_and_generate_sevent

    def self.all_areas
      self.all
    end

    def self.free_areas
      self.joins(:astatuses).where(:c80_estate_astatuses => {tag: 'free'})
    end

    # посчитает кол-во свободных метров
    def self.free_areas_sq
      sum = 0
      self.free_areas.each do |area|
        # area_prop_square = area.item_props.where(:prop_name_id => 9)
        area_prop_square = area.square_value
        sum += area_prop_square#.first.value.to_i
      end
      sum
    end

    def self.busy_areas
      self.joins(:astatuses).where(:c80_estate_astatuses => {tag: 'busy'})
    end

    # посчитает кол-во занятых метров
    def self.busy_areas_sq
      sum = 0
      self.busy_areas.each do |area|
        area_prop_square = area.item_props.where(:prop_name_id => 9)
        if area_prop_square.present?
          sum += area_prop_square.first.value.to_i
        end
      end
      sum
    end

    def self.all_areas_sq
      sum = 0
      self.all.each do |area|
        area_prop_square = area.item_props.where(:prop_name_id => 9)
        if area_prop_square.present?
          sum += area_prop_square.first.value.to_i
        end
      end
      sum
    end

    def self.where_price_range(range)
      self.joins(:item_props)
          .where(c80_estate_item_props: {prop_name_id: 1})
          .where('c80_estate_item_props.value > ?', range.split(',')[0].to_i-1)
          .where('c80_estate_item_props.value < ?', range.split(',')[1].to_i+1)
    end

    def self.where_square_range(range)
      C80Estate::Area.joins(:item_props)
          .where(c80_estate_item_props: {prop_name_id: 9})
          .where('c80_estate_item_props.value > ?', range.split(',')[0].to_i-1)
          .where('c80_estate_item_props.value < ?', range.split(',')[1].to_i+1)
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
                                        {value: row['price'].to_i, area_id: area.id, prop_name_id: 1},
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

    def has_astatus?
      errors.add_to_base 'Укажите статус площади' if self.astatuses.blank?
    end

    def atype_title
      res = "-"
      if atype.present?
        res = atype.title
      end
      res
    end

    def property_title
      res = "-"
      if property.present?
        res = property.title
      end
      res
    end

    def astatus_title
      res = "-"
      if astatuses.count > 0
        res = astatuses.first.title
      end
      res
    end

    def astatus_id
      res = -1
      if astatuses.count > 0
        res = astatuses.first.id
      end
      res
    end

    def astatus_tag
      res = -1
      if astatuses.count > 0
        res = astatuses.first.tag
      end
      res
    end

    def is_free?
      astatus_tag == 'free'
    end

    def is_busy?
      astatus_tag == 'busy'
    end

    def assigned_person_title
      res = "-"
      if assigned_person.present?
        res = assigned_person.email
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

    def price_value
      res = 0
      p = item_props.where(:prop_name_id => 1)
      if p.count > 0
        res = p.first.value.to_i
      end
      res
    end

    def square_value
      res = 0
      p = item_props.where(:prop_name_id => 9)
      if p.count > 0
        res = p.first.value.to_f
      end
      res
    end

    def power_price_value
      price_value * 1.0 * square_value
    end

    def main_image_url
      url = 'no_thumb.png'
      if aphotos.count > 0
        url = aphotos.first.image.thumb512
      end
      url
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

        # см [*]
        # if last_known_sevent == ''
        #   pparams[:created_at] = self.created_at
        # end
        #
        # pparams = {
        #     atype_id: nil,
        #     property_id: self.property_id,
        #     sevent_id: s.id
        # }

        # генерим запись с общими данными
        # связываем её с Sevent
        # чтобы можно было удалить как dependent => destroy
        # Pstat.create!(pparams)

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

  end
end