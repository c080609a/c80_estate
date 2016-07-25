# ПОДкатегории строительных материалов
ActiveAdmin.register C80Estate::Atype, :as => 'Atype' do

  menu :label => "Типы", :parent => "Настройки", :if => proc { current_admin_user.can_view_settings? }

  permit_params :title,
                :slug,
                :prop_name_ids => []

  config.sort_order = 'id_asc'

  # controller do
  #   cache_sweeper :strsubcat_sweeper, :only => [:update,:create,:destroy]
  # end

  before_filter :skip_sidebar!, :only => :index

  # filter :title

  # controller do
  #   cache_sweeper :suit_sweeper, :only => [:update,:create,:destroy]
  # end

  index do
    selectable_column
    id_column
    column :title
    actions
  end

  form(:html => {:multipart => true}) do |f|

    f.inputs "Свойства" do
      f.input :title
    end

    f.inputs "Характеристики, которыми описываются объекты недвижимости и площади этого типа", :class => 'collapsed' do
      f.input :prop_names, :as => :check_boxes
    end

    f.actions
  end

end