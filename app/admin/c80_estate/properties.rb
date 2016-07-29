ActiveAdmin.register C80Estate::Property, as: 'Property' do

  # scope_to :current_admin_user, association_method: :sites_list

  menu :label => "Объекты недвижимости", priority: 2

  permit_params :title,
                :desc,
                :address,
                :latitude,
                :longitude,
                # :atype_id,
                :owner_id,
                :owner_type,
                :assigned_person_id,
                :assigned_person_type,
                :pphotos_attributes => [:id,:image,:_destroy],
                :plogos_attributes => [:id,:image,:_destroy]

  batch_action :destroy, false

  config.clear_action_items!

  action_item :new_model, :only => :index do
    if current_admin_user.can_create_properties?
      link_to I18n.t("active_admin.new_model"), '/admin/properties/new', method: :get
    end
  end

  config.sort_order = 'id_asc'

  filter :title
  filter :created_at
  filter :updated_at
  filter :assigned_person_id,
         :as => :select,
         :collection => -> {AdminUser.all.map{|u| ["#{u.email}", u.id]}},
         :input_html => { :class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}

  index do
    selectable_column
    column '' do |prop|
      "<div class='image_vertical properties_index_logo'>
      <span></span><img src='#{image_path(prop.logo_path)}'>
      </div>".html_safe
    end
    column :title
    column :address
    column :gps do |prop|
      "#{prop.latitude},#{prop.longitude}"
    end
    column :assigned_person do |prop|
      prop.assigned_person_title
    end
    # column :atype do |prop|
    #   prop.atype.title
    # end
    # actions

    column '' do |property|
      link_to I18n.t("active_admin.view"), "/admin/properties/#{property.id}", class: 'member_link'
    end
    column '' do |property|
      if current_admin_user.can_edit_property?(property)
        link_to I18n.t("active_admin.edit"), "/admin/properties/#{property.id}/edit", class: 'member_link'
      end
    end

  end

  form(:html => {:multipart => true}) do |f|

    f.inputs 'Свойства' do
      f.input :title
      f.input :assigned_person,
              :input_html => { :class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px'},
              :collection => AdminUser.all.map{|u| ["#{u.email}", u.id]}
      f.input :assigned_person_type, :input_html => { :value => "AdminUser" }, as: :hidden
      # f.input :atype, :input_html => { :class => 'selectpicker', 'data-size' => "5", 'data-width' => '400px'}

      if f.object.new_record?
        f.input :owner_id, :input_html => { :value => current_admin_user.id }, as: :hidden
        f.input :owner_type, :input_html => { :value => "AdminUser" }, as: :hidden
      end

      f.input :address
      f.input :latitude
      f.input :longitude

      f.has_many :pphotos, :allow_destroy => true do |gp|
        gp.input :image,
                 :as => :file,
                 :hint => image_tag(gp.object.image.thumb512)
      end

      f.has_many :plogos, :allow_destroy => true do |gp|
        gp.input :image,
                 :as => :file,
                 :hint => image_tag(gp.object.image.thumb128)
      end

    end

    f.actions
  end

  show do
    render partial: 'show_property', locals: { property:resource }
    active_admin_comments
  end

end