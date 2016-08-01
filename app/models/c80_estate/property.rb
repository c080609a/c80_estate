module C80Estate
  class Property < ActiveRecord::Base
    belongs_to :atype
    belongs_to :owner, :polymorphic => true
    belongs_to :assigned_person, :polymorphic => true
    has_many :item_props, :dependent => :destroy
    has_many :pphotos, :dependent => :destroy   # одна или несколько фоток
    accepts_nested_attributes_for :pphotos,
                                  :reject_if => lambda { |attributes|
                                    !attributes.present?
                                  },
                                  :allow_destroy => true
    has_many :plogos, :dependent => :destroy   # одна или несколько фоток
    accepts_nested_attributes_for :plogos,
                                  :reject_if => lambda { |attributes|
                                    !attributes.present?
                                  },
                                  :allow_destroy => true
    has_many :areas, :dependent => :destroy
    has_many :comments, :dependent => :destroy
    has_many :sevents, :dependent => :destroy
    has_many :pstats, :dependent => :destroy

    # этот метод для ActiveRecordCollection of Properties
    def self.areas_count
      ac = 0
      self.all.each do |prop|
        ac += prop.areas.count
      end
      ac
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
      pstats.last.sevent.auser.email
    end

    def square_value
      sum = 0
      areas.all.each do |area|
        sum += area.square_value
      end
      sum
    end

    def power_price_value
      sum = 0
      areas.all.each do |area|
        sum += area.power_price_value
      end
      sum
    end

  end
end