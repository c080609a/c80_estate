ActiveAdmin.register C80Estate::Property, as: 'Property' do

  # scope_to :current_admin_user, association_method: :sites_list

  menu :label => "Объекты недвижимости"

  permit_params :title,
                :desc,
                :address,
                :latitude,
                :longitude,
                :atype_id,
                :owner_id,
                :owner_type

  config.sort_order = 'id_asc'

  index do
    selectable_column
    column :title
    column :atype do |prop|
      prop.atype.title
    end
    actions
  end

  form(:html => {:multipart => true}) do |f|

    f.inputs 'Свойства' do
      f.input :title
      f.input :atype, :input_html => { :class => 'selectpicker', 'data-size' => "5", 'data-width' => '400px'}
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

    end

    f.actions
  end

end