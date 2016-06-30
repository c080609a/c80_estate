ActiveAdmin.register C80Estate::Area, as: 'Area' do

  # scope_to :current_admin_user, association_method: :sites_list

  menu :label => "Площади"

  permit_params :title,
                :owner_id,
                :owner_type,
                :atype,
                :property

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
      f.input :owner_id, :input_html => { :value => current_admin_user.id }, as: :hidden
      f.input :owner_type, :input_html => { :value => "AdminUser" }, as: :hidden
    end

    f.actions
  end

end