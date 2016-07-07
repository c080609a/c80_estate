# ПОДкатегории строительных материалов
ActiveAdmin.register C80Estate::Astatus, :as => 'Astatus' do

  menu :label => "Статусы", :parent => "Настройки"

  permit_params :title

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

    f.actions
  end

end