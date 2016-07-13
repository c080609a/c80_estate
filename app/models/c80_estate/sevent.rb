module C80Estate
  class Sevent < ActiveRecord::Base
    belongs_to :area
    belongs_to :atype
    belongs_to :property
    belongs_to :astatus
    belongs_to :auser, :polymorphic => true

=begin
    def self.all_areas
      self.all
    end

    def self.free_areas
      self.joins(:astatuses).where(:c80_estate_astatuses => { tag: 'free'})
    end

    def self.busy_areas
      self.joins(:astatuses).where(:c80_estate_astatuses => { tag: 'busy'})
    end
=end

    def area_title
      res = "-"
      if area.present?
        res = area.title
      end
      res
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
      if astatus.present?
        res = astatus.title
      end
      res
    end

    def auser_title
      res = "-"
      if auser.present?
        res = auser.email
      end
      res
    end

  end
end