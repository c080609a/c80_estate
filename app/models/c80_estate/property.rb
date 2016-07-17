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
    has_many :areas, :dependent => :destroy
    has_many :comments, :dependent => :destroy
    has_many :sevents, :dependent => :destroy
    has_many :pstats, :dependent => :destroy

    def assigned_person_title
      res = "-"
      if assigned_person.present?
        res = assigned_person.email
      end
      res
    end

  end
end