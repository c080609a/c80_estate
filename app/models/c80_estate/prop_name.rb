module C80Estate
  class PropName < ActiveRecord::Base

    # validates_with PropNameValidator

    # у этой (абстрактной по сути) характеристики есть конкретные порождения - свойства.
    has_many :item_props, :dependent => :destroy
    has_and_belongs_to_many :atypes, :join_table => 'c80_estate_atypes_prop_names'

    # каждое свойство принадлежит какой-то единице измерения
    belongs_to :uom

    # accepts_nested_attributes_for :uom
    # has_and_belongs_to_many :main_props
    # has_and_belongs_to_many :common_props
    # has_and_belongs_to_many :price_props
    default_scope {order(:title => :asc)}
  end
end