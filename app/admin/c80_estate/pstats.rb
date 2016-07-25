ActiveAdmin.register C80Estate::Pstat, as: 'Pstat' do

  # scope_to :current_admin_user, association_method: :sites_list

  menu :label => "Объекты", :parent => 'Статистика', if: proc{ current_admin_user.can_view_statistics? }

  config.sort_order = 'id_asc'

  filter :property_id,
         :as => :select,
         :collection => -> { C80Estate::Property.all.map { |p| ["#{p.title}", p.id] } },
         :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}

  filter :atype_id,
         :as => :select,
         :collection => -> { C80Estate::Atype.all.map { |p| ["#{p.title}", p.id] } },
         :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}

  filter :created_at

  index do
    selectable_column
    column :property do |ptype|
      ptype.property_title
    end
    column :atype do |ptype|
      ptype.atype_title
    end
    column :free_areas
    column :busy_areas
    column :coef_busy
    column :coef_busy_sq
    column :created_at
    actions
  end

end