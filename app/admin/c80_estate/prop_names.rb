ActiveAdmin.register C80Estate::PropName, as: 'PropName' do

  menu :label => "Имена свойств", :parent => "Настройки"

  permit_params :title,
                :uom_id,
                :is_excluded_from_filtering,
                :is_normal_price

  config.sort_order = 'title_asc'

  filter :title
  filter :atypes
  filter :is_excluded_from_filtering
  filter :is_normal_price

  # controller do
  #   cache_sweeper :suit_sweeper, :only => [:update,:create,:destroy]
  # end

  index do
    # selectable_column
    id_column

    column :title
    column :uom
    column :is_excluded_from_filtering
    column :is_normal_price

    actions
  end

  form(:html => {:multipart => true}) do |f|

    f.inputs "Свойства" do
      f.input :title
      f.input :uom, :input_html => { :class => 'selectpicker', 'data-size' => "5", 'data-width' => '400px'}
      f.input :is_excluded_from_filtering,
              :hint => "Если да, то это свойство не будет фигурировать в списке фильтрации".html_safe

      f.input :is_normal_price,
              :hint => "Является ли свойство ценой".html_safe

    end
    f.actions
  end

end