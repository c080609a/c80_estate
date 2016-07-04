# ПОДкатегории строительных материалов
ActiveAdmin.register C80Estate::RoleType, :as => 'RoleType' do

  menu :label => "Роли", :parent => "Настройки"

  permit_params :title,
                :desc

  config.sort_order = 'id_asc'

  # controller do
  #   cache_sweeper :strsubcat_sweeper, :only => [:update,:create,:destroy]
  # end

  # before_filter :skip_sidebar!, :only => :index

  filter :title

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
      f.input :desc, input_html: { rows: 3 }
    end

    f.actions
  end

end