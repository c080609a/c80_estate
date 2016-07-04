module C80Estate
  class Area < ActiveRecord::Base
    belongs_to :property
    belongs_to :atype
    belongs_to :owner, :polymorphic => true
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
  end
end