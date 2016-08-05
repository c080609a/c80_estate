ActiveAdmin.register C80Estate::Area, as: 'Area' do

  # scope_to :current_admin_user, association_method: :sites_list

  menu :label => 'Площади', priority: 3

  permit_params :title,
                :desc,
                :owner_id,
                :owner_type,
                :assigned_person_id,
                :assigned_person_type,
                :atype_id,
                :property_id,
                :astatus_ids => [],
                :aphotos_attributes => [:id, :image, :_destroy],
                :item_props_attributes => [:value, :_destroy, :prop_name_id, :id]

  batch_action :destroy, false

  batch_action 'Задать цену', form: {
                                # type: %w[Offensive Spam Other],
                                val: :text,
                                # notes:  :textarea,
                                # hide:   :checkbox,
                                # date:   :datepicker
                            } do |ids, inputs|
    # inputs is a hash of all the form fields you requested
    redirect_to collection_path, notice: [ids, inputs].to_s

  end

  batch_action 'Задать объём площади', form: {
                                         # type: %w[Offensive Spam Other],
                                         val: :text,
                                         # notes:  :textarea,
                                         # hide:   :checkbox,
                                         # date:   :datepicker
                                     } do |ids, inputs|
    # inputs is a hash of all the form fields you requested
    redirect_to collection_path, notice: [ids, inputs].to_s
  end

  config.clear_action_items!

  action_item :new_model, :only => :index do
    if current_admin_user.can_create_areas?
      link_to I18n.t("active_admin.new_model"), '/admin/areas/new', method: :get
    end
  end

  action_item only: [:show] do
    if current_admin_user.can_edit_area?(resource)
      link_to I18n.t("active_admin.edit_model"), edit_admin_area_path(resource)
    end
  end

  action_item only: [:show] do
    if current_admin_user.can_delete_area?
      link_to I18n.t("active_admin.delete_model"),
              admin_area_path(resource),
              data: {
                  confirm: 'Вы уверены, что хотите удалить это?',
                  method: 'delete'
              }
      # <a class="delete_link member_link" data-confirm="Вы уверены, что хотите удалить это?" rel="nofollow" data-method="delete" href="/admin/areas/1">Удалить</a>
    end
  end

  config.sort_order = 'id_asc'

  filter :atype_id,
         :label => 'Тип площади',
         :as => :select,
         :collection => -> { C80Estate::Atype.all.map { |p| ["#{p.title}", p.id] } },
         :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}
  filter :property_id,
         :label => 'Объект недвижимости',
         :as => :select,
         :collection => -> { C80Estate::Property.all.map { |p| ["#{p.title}", p.id] } },
         :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}

  # filter :item_prop_square_val_in,
  #        :as => :string,
  #        :label => 'Площадь (м.кв.)'

  filter :item_prop_square_val_in,
         :as => :string,
         :label => 'Площадь (м.кв.)',
         :input_html => {data: {
             # provide: 'slider',
             slider_ticks: C80Estate::ItemProp.all_uniq_values(9).to_json, #'[0, 1, 2, 3]',
             slider_labels: C80Estate::ItemProp.all_uniq_values(9).to_json, #'["none", short", "medium","long"]',
             slider_min: C80Estate::ItemProp.all_uniq_values(9).sort.first,
             slider_max: C80Estate::ItemProp.all_uniq_values(9).sort.last,
             slider_step: 1,
             slider_value: 0,
             slider_range: true,
             slider_tooltip: 'hide'
         }}

  filter :item_prop_price_val_in,
         :as => :string,
         :label => 'Цена (руб/м.кв в месяц)',
         :input_html => {data: {
             #provide: 'slider',
             slider_ticks: C80Estate::ItemProp.all_uniq_values(1).to_json, #'[0, 1, 2, 3]',
             slider_labels: C80Estate::ItemProp.all_uniq_values(1).to_json, #'["none", short", "medium","long"]',
             slider_min: C80Estate::ItemProp.all_uniq_values(1).sort.first,
             slider_max: C80Estate::ItemProp.all_uniq_values(1).sort.last,
             slider_step: 1,
             slider_value: 0,
             slider_range: true,
             slider_tooltip: 'hide'
         }}

  filter :item_prop_oenter_in,
         :as => :select,
         :collection => [['Есть', 11], ['Нет', 10]],
         :label => 'Отдельный вход с улицы',
         :input_html => {:class => 'selectpicker', 'data-size' => "3", 'data-width' => '100%'}

  filter :item_prop_floor_val_in,
         :as => :select,
         :collection => -> { C80Estate::ItemProp.all_uniq_values(5) },
         :label => 'Этаж',
         :input_html => {:class => 'selectpicker', 'data-size' => "3", 'data-width' => '100%'}

  # filter :title
  filter :assigned_person_id_in,
         :label => 'Назначенный пользователь',
         :as => :select,
         :collection => -> { AdminUser.all.map { |u| ["#{u.email} (#{u.assigned_areas_count})", u.id] } },
         :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '100%'}
  filter :created_at
  filter :updated_at

  scope "All", :all_areas
  scope "Free", :free_areas
  scope "Busy", :busy_areas

  index do
    selectable_column
    column :title do |area|
      link_to area.title, "/admin/areas/#{area.id}", title: I18n.t("active_admin.view")
    end
    column :atype do |area|
      area.atype_title
    end
    column '<abbr title="За м.кв. в месяц">Цена м.кв.</abbr>'.html_safe do |area|
      "#{area.price_value.to_s(:rounded, :precision => 2)} руб"
    end
    column '<abbr title="Стоимость всей площади в месяц. Число PxS, где P - цена за м.кв. в месяц, S - метраж площади в м.кв.">Цена площади</abbr>'.html_safe do |area|
      klass = ''
      title = 'Цена за площадь рассчитана'
      if area.is_locked_area_price?
        klass = 'locked'
        title = 'Явно указана цена за площадь, цена за метр рассчитана от этого числа'
      end
      "<span title='#{title}' class='#{klass}'>#{area.power_price_value.to_s(:rounded, :precision => 2)} руб</span>".html_safe
    end
    column 'Метраж' do |area|
      "#{area.square_value.to_s(:rounded, :precision => 2)} м<sup>2</sup>".html_safe
    end
    column :property do |area|
      "<div class='image_vertical properties_index_logo'>
      <span></span><a href='/admin/areas?utf8=✓&q%5Bproperty_id_eq%5D=#{area.property.id}&commit=Фильтровать&order=id_asc'><img src='#{image_path(area.property.logo_path)}'>
      </div><span class='properties_index_logo_title'>#{area.property_title}</span></a>".html_safe

    end
    column :astatuses do |area|
      "<span class='status_#{area.astatus_tag}'>#{area.astatus_title}</span>".html_safe
    end
    column :assigned_person do |area|
      area.property.assigned_person_title
    end
    # actions
    # column '' do |area|
    #   link_to I18n.t("active_admin.view"), "/admin/areas/#{area.id}", class: 'member_link'
    # end
    column '' do |area|
      if current_admin_user.can_edit_area?(area)
        link_to I18n.t("active_admin.edit"), "/admin/areas/#{area.id}/edit", class: 'member_link'
      end
    end
  end

  form(:html => {:multipart => true}) do |f|

    f.inputs 'Свойства' do
      f.input :title
      f.input :atype, :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px'}
      f.input :property,
              :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px'},
              :collection => C80Estate::Property.where_assig_user(current_admin_user).map { |p| ["#{p.title}", p.id] }
      # f.input :assigned_person,
      #         :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px'},
      #         :collection => AdminUser.all.map { |u| ["#{u.email}", u.id] }
      # f.input :assigned_person_type, :input_html => {:value => "AdminUser"}, as: :hidden
      f.input :astatuses,
              :input_html => {:class => 'selectpicker', 'data-size' => "10", 'data-width' => '400px', :multiple => false}
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

      if f.object.new_record?
        f.input :owner_id, :input_html => {:value => current_admin_user.id}, as: :hidden
        f.input :owner_type, :input_html => {:value => "AdminUser"}, as: :hidden
      end

    end

    f.actions
  end

  show do
    render partial: 'show_area', locals: { area:resource }
    active_admin_comments
  end

end