ActiveAdmin.register AdminUser do

  permit_params :email,
                :password,
                :password_confirmation,
                :roles_attributes => [:id, :role_type_id]

  batch_action :destroy, false

  controller do

    def update
      if params[:admin_user][:password].blank?
        params[:admin_user].delete('password')
        params[:admin_user].delete('password_confirmation')
      end
      super
    end

  end

  # menu :if => proc {current_admin_user.email == "tz007@mail.ru"}
  menu label: 'Пользователи',
       :if => proc { current_admin_user.can_view_users? },
       :priority => 9

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :role do |user|
      user.role_type_title
    end
    column 'Площадей' do |user|
      user.assigned_areas_count
    end
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Свойства" do
      f.input :email

      # if f.object.new_record?
        f.input :password
        f.input :password_confirmation
      # else
        # f.input :password
        # f.input :password_confirmation
      # end

      # f.input :roles
      f.has_many :roles,
                 new_record: true,
                 allow_destroy: false do |r|
        r.input :role_type
      end
    end
    f.actions
  end

end
