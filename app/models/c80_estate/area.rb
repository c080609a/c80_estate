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
    has_many :aphotos, :dependent => :destroy   # одна или несколько фоток
    accepts_nested_attributes_for :aphotos,
                                  :reject_if => lambda { |attributes|
                                    !attributes.present?
                                  },
                                  :allow_destroy => true
    has_many :comments, :dependent => :destroy   # площадь можно прокомментировать
    has_and_belongs_to_many :astatuses,         # единственный статус: либо занята, либо свободна
                            :join_table => 'c80_estate_areas_astatuses'

    has_many :sevents, :dependent => :destroy

    after_create :create_initial_sevent
    after_update :check_and_generate_sevent

    def self.all_areas
      self.all
    end

    def self.free_areas
      self.joins(:astatuses).where(:c80_estate_astatuses => { tag: 'free'})
    end

    def self.busy_areas
      self.joins(:astatuses).where(:c80_estate_astatuses => { tag: 'busy'})
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
      Rails.logger.debug "<Area.create_initial_sevent>"

      Sevent.create!({
                         area_id: self.id,
                         atype_id: self.atype_id,
                         property_id: self.property_id,
                         astatus_id: self.astatus_id,
                         auser_id: self.owner_id, # инициатор события - создатель Площади
                         auser_type: 'AdminUser'
                     })

    end

    def check_and_generate_sevent
      Rails.logger.debug "<Area.check_and_generate_sevent>"

      # находим последнее известное событие
      # фиксируем его статус
      last_known_sevent = self.sevents.last.astatus.tag

      # если статус этого события отличен
      # от нового статуса - генерим событие
      if last_known_sevent != self.astatuses.first.tag
        Sevent.create!({
                           area_id: self.id,
                           atype_id: self.atype_id,
                           property_id: self.property_id,
                           astatus_id: self.astatus_id,
                           auser_id: self.owner_id, # инициатор события - редактор Площади
                           auser_type: 'AdminUser'
                       })
      end

    end

  end
end