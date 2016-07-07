ActiveAdmin.register C80Estate::Area, as: 'Area' do

  # scope_to :current_admin_user, association_method: :sites_list

  menu :label => "Площади"

  permit_params :title,
                :desc,
                :owner_id,
                :owner_type,
                :assigned_person_id,
                :assigned_person_type,
                :atype_id,
                :property_id,
                :astatus_ids => [],
                :aphotos_attributes => [:id,:image,:_destroy],
                :item_props_attributes => [:value, :_destroy, :prop_name_id, :id]

  config.sort_order = 'id_asc'

  filter :title
  filter :property_id,
         :as => :select,
         :collection => -> {C80Estate::Property.all.map { |p| ["#{p.title}", p.id]}},
         :input_html => { :class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}
  filter :assigned_person_id,
         :as => :select,
         :collection => -> {AdminUser.all.map{|u| ["#{u.email}", u.id]}},
         :input_html => { :class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}
  filter :created_at
  filter :updated_at

  scope  "All", :all_areas
  scope  "Free", :free_areas
  scope  "Busy", :busy_areas

  index do
    selectable_column
    column :title
    column :atype do |area|
      area.atype_title
    end
    column :property do |area|
      area.property_title
    end
    column :astatuses do |area|
      area.astatus_title
    end
    column :assigned_person do |area|
      area.assigned_person_title
    end
    actions
  end

  form(:html => {:multipart => true}) do |f|

    f.inputs 'Свойства' do
      f.input :title
      f.input :atype, :input_html => { :class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px'}
      f.input :property, :input_html => { :class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px'}
      f.input :assigned_person,
              :input_html => { :class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px'},
              :collection => AdminUser.all.map{|u| ["#{u.email}", u.id]}
      f.input :assigned_person_type, :input_html => { :value => "AdminUser" }, as: :hidden
      f.input :astatuses,
              :input_html => { :class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px', :multiple => false}
      f.input :desc, :as => :ckeditor

      f.inputs "Свойства" do

        f.has_many :item_props, :allow_destroy => true do |item_prop|
          item_prop.input :prop_name
          item_prop.input :value
        end

      end

      f.has_many :aphotos, :allow_destroy => true do |gp|
        gp.input :image,
                 :as => :file,
                 :hint => image_tag(gp.object.image.thumb512)
      end

      f.input :owner_id, :input_html => { :value => current_admin_user.id }, as: :hidden
      f.input :owner_type, :input_html => { :value => "AdminUser" }, as: :hidden
    end

    f.actions
  end

end