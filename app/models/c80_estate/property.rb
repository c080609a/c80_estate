module C80Estate
  class Property < ActiveRecord::Base
    belongs_to :atype
    belongs_to :owner, :polymorphic => true
    has_many :item_props, :dependent => :destroy
    has_many :pphotos, :dependent => :destroy   # одна или несколько фоток
    has_many :areas, :dependent => :destroy
    has_many :comments, :dependent => :destroy
  end
end