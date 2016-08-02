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

    # применим для коллекций
    # def self.average_price
    #
    #   areas_counter = 0
    #   price_sum = 0
    #
    #   self.all.each do |prop|
    #     prop.areas.all.each do |area|
    #       price_sum += area.price_value
    #       areas_counter += 1
    #     end
    #   end
    #
    #   if areas_counter != 0
    #     price_sum*1.0 / areas_counter
    #   else
    #     0
    #   end
    # end

    def average_price
      price_sum = 0
      areas.all.each do |area|
        price_sum += area.price_value
      end

      if areas.all.count != 0
        price_sum*1.0 / areas.all.count
      else
        0
      end

    end

    def average_price_busy

      busy_areas_count = 0
      price_sum = 0

      areas.all.each do |area|
        if area.is_busy?
          busy_areas_count += 1
          price_sum += area.price_value
        end
      end

      if busy_areas_count != 0
        price_sum*1.0 / busy_areas_count
      else
        0
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