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
        area_prop_square = area.item_props.where(:prop_name_id => 9)
        if area_prop_square.present?
          sum += area_prop_square.first.value.to_i
        end
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

  end
end