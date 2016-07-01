ActiveAdmin.register C80Estate::Area, as: 'Area' do

  # scope_to :current_admin_user, association_method: :sites_list

  menu :label => "Площади"

  permit_params :title,
                :desc,
                :owner_id,
                :owner_type,
                :atype_id,
                :property_id,
                :aphotos_attributes => [:id,:image,:_destroy],
                :item_props_attributes => [:value, :_destroy, :prop_name_id, :id]

  config.sort_order = 'id_asc'

  index do
    column :title
    actions
  end

  form(:html => {:multipart => true}) do |f|

    f.inputs 'Свойства' do
      f.input :title
      f.input :atype
      f.input :property
      f.input :desc, :as => :ckeditor
      f.has_many :aphotos, :allow_destroy => true do |gp|
        gp.input :image,
                 :as => :file,
                 :hint => image_tag(gp.object.image.thumb512)
      end

      f.input :owner_id, :input_html => { :value => current_admin_user.id }, as: :hidden
      f.input :owner_type, :input_html => { :value => "AdminUser" }, as: :hidden
    end

    f.inputs "Характеристики" do

      f.has_many :item_props, :allow_destroy => true do |item_prop|
        item_prop.input :prop_name
        item_prop.input :value
      end

    end

    f.actions
  end

end