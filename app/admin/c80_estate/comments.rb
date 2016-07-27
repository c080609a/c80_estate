ActiveAdmin.register ActiveAdmin::Comment, :as => 'Comment' do

  menu label: 'Комментарии',
       :if => proc { current_admin_user.can_view_comments? },
       :priority => 12

  batch_action :destroy, false

  config.clear_action_items!

  index do
    # selectable_column
    id_column
    column :author
    column :resource
    column :body
    column :created_at
  end

  filter :author_id,
         :label => 'Автор',
         :as => :select,
         :collection => -> { AdminUser.all.map { |u| ["#{u.email}", u.id] } },
         :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}
  filter :created_at

end
