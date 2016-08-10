module C80Estate
  class Property < ActiveRecord::Base
    belongs_to :atype
    belongs_to :owner, :polymorphic => true
    belongs_to :assigned_person, :polymorphic => true
    # has_many :item_props, :dependent => :destroy
    has_many :pphotos, :dependent => :destroy # одна или несколько фоток
    accepts_nested_attributes_for :pphotos,
                                  :reject_if => lambda { |attributes|
                                    !attributes.present?
                                  },
                                  :allow_destroy => true
    has_many :plogos, :dependent => :destroy # одна или несколько фоток
    accepts_nested_attributes_for :plogos,
                                  :reject_if => lambda { |attributes|
                                    !attributes.present?
                                  },
                                  :allow_destroy => true
    has_many :areas, :dependent => :destroy
    has_many :comments, :dependent => :destroy
    has_many :sevents, :dependent => :destroy
    has_many :pstats, :dependent => :destroy

    # scope :sort_chart, -> {order(:ord => :asc)}

    def self.sorted_chart
      self.all.sort_by(&:busy_coef).reverse!
    end

    # вернуть самый свежий объект с данными события Pstat
    def last_known_stats(atype_id: nil)
      pstats.where(:atype_id => atype_id).ordered_by_created_at.last
    end

    # выдать действующий на данный момент коэф-т занятости
    def busy_coef(atype_id: nil)
      # необходимо обратиться к самому последнему (общему?) событию Pstat
      pstats.where(:atype_id => atype_id).ordered_by_created_at.last.coef_busy
    end

    # выдать действующий на данный момент коэф-т занятости в метрах
    def busy_coef_sq(atype_id: nil)
      # необходимо обратиться к самому последнему (общему?) событию Pstat
      pstats.where(:atype_id => atype_id).ordered_by_created_at.last.coef_busy_sq
    end

    # этот метод для ActiveRecordCollection of Properties
    def self.areas_count
      ac = 0
      self.all.each do |prop|
        ac += prop.areas.count
      end
      ac
    end

    # посчитает среднее значение средних цен по коллекции
    def self.average_price(atype_id: nil)

      res = 0.0
      sum = 0.0

      c = self.all.count
      if c > 0
        self.all.each do |prop|
          sum += prop.average_price(atype_id:atype_id)
        end
        res = sum / c
      end

      res
    end

    # посчитает среднее значение средних цен ЗАНЯТЫХ ПЛОЩАДЕЙ по коллекции
    # можно указать тип
    def self.average_price_busy(atype_id: nil)

      res = 0.0
      sum = 0.0

      c = self.all.count
      if c > 0
        self.all.each do |prop|
          sum += prop.average_price_busy(atype_id:atype_id)
        end
        res = sum / c
      end

      res
    end

    # для селекта формы админки Area выдать
    # список объектов, на которые назначен пользователь
    # если юзер - админ - ему выдаются все объекты
    def self.where_assig_user(user)
      if user.can_create_properties?
        C80Estate::Property.all
      else
        C80Estate::Property.where(:assigned_person_id => user.id)
      end

    end

    def average_price(atype_id: nil)

      if atype_id.nil?
        ars = areas.all
      else
        ars = areas.where_atype(atype_id)
      end

      price_sum = 0.0

      ars.each do |area|
        price_sum += area.price_value
      end

      if ars.count != 0
        price_sum*1.0 / ars.count
      else
        0.0
      end

    end

    # рассчитать среднюю цену среди занятых у конкретного объекта
    # можно указать дополнительно тип
    def average_price_busy(atype_id: nil)

      if atype_id.nil?
        ars = areas.all
      else
        ars = areas.where_atype(atype_id)
      end

      busy_areas_count = 0
      price_sum = 0.0

      ars.each do |area|
        if area.is_busy?
          busy_areas_count += 1
          price_sum += area.price_value
        end
      end

      if busy_areas_count != 0
        price_sum*1.0 / busy_areas_count
      else
        0.0
      end

    end

    def assigned_person_title
      res = "-"
      if assigned_person.present?
        res = assigned_person.email
      end
      res
    end

    def owner_title
      res = "-"
      if owner.present?
        res = owner.email
      end
      res
    end

    # TODO:: при построении индексной таблицы из 100 строк происходит 100 запросов к базе типа COUNT(*). Добавить before_update метод и поле logo_path и вычислять путь к лого в before update
    def logo_path
      url = 'property_default_logo.png'
      if plogos.count > 0
        url = plogos.first.image.thumb256
      end
      url
    end

    def main_image_url
      url = 'no_thumb.png'
      if pphotos.count > 0
        url = pphotos.first.image.thumb512
      end
      url
    end

    def last_updater
      res = '-'
      if pstats.count > 0
        res = pstats.last.sevent.auser.email
      end
    end

    def square_value
      sum = 0.0
      areas.all.each do |area|
        sum += area.square_value
      end
      sum
    end

    def power_price_value
      sum = 0.0
      areas.all.each do |area|
        sum += area.power_price_value
      end
      sum
    end

  end
end