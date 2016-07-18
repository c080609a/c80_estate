ActiveAdmin.register C80Estate::Sevent, as: 'Sevent' do

  # scope_to :current_admin_user, association_method: :sites_list

  menu :label => "Площади", :parent => 'Статистика'

  permit_params :area_id,
                :atype_id,
                :property_id,
                :astatus_id,
                :auser_id,
                :auser_type

  config.sort_order = 'id_asc'

  # filter :property_id,
  #        :as => :select,
  #        :collection => -> { C80Estate::Property.all.map { |p| ["#{p.title}", p.id] } },
  #        :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}
  filter :area_id,
         :as => :select,
         :collection => -> { C80Estate::Area.all.map { |a|
           ["#{a.property.title}: #{a.title}", a.id]
         } },
         :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}
  # filter :atype_id,
  #        :as => :select,
  #        :collection => -> { C80Estate::Atype.all.map { |p| ["#{p.title}", p.id] } },
  #        :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}
  # filter :auser_id,
  #        :as => :select,
  #        :collection => -> { AdminUser.all.map { |u| ["#{u.email}", u.id] } },
  #        :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}
  filter :created_at
  # filter :updated_at

  # scope  "All", :all_areas
  # scope  "Free", :free_areas
  # scope  "Busy", :busy_areas

  index do
    selectable_column
    column :area do |sevent|
      sevent.area_title
    end
    column :astatus do |sevent|
      sevent.astatus_title
    end
    column :created_at
    column :property do |sevent|
      sevent.property_title
    end
    actions
  end

  form(:html => {:multipart => true}) do |f|

    f.inputs 'Свойства' do
      f.input :area, :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px'}
      f.input :atype, :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px'}
      f.input :property, :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px'}
      f.input :astatus,
              :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px', :multiple => false}
      f.input :auser,
              :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px'},
              :collection => AdminUser.all.map { |u| ["#{u.email}", u.id] }
      f.input :auser_type, :input_html => {:value => "AdminUser"}, as: :hidden

      f.actions
    end

  end
end