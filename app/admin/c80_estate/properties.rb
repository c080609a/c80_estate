ActiveAdmin.register C80Estate::Property, as: 'Property' do

  # scope_to :current_admin_user, association_method: :sites_list

  menu :label => "Объекты недвижимости"

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
    actions
  end

  form(:html => {:multipart => true}) do |f|

    f.inputs 'Свойства' do
      f.input :title
      f.input :assigned_person,
              :input_html => { :class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px'},
              :collection => AdminUser.all.map{|u| ["#{u.email}", u.id]}
      f.input :assigned_person_type, :input_html => { :value => "AdminUser" }, as: :hidden
      # f.input :atype, :input_html => { :class => 'selectpicker', 'data-size' => "5", 'data-width' => '400px'}
      f.input :owner_id, :input_html => { :value => current_admin_user.id }, as: :hidden
      f.input :owner_type, :input_html => { :value => "AdminUser" }, as: :hidden
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

end