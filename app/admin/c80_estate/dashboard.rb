ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do

    columns do

      column do

        panel 'Объекты недвижимости', class: 'clearfix proplist' do
          # para "Объекты недвижимости", class: 'title'
          C80Estate::Property.all.each do |prop|
            render partial: 'prop_in_list', locals: {prop: prop}
          end
        end

        panel 'Типы площадей', class: 'clearfix' do
          # para 'Типы площадей', class: 'title'
          C80Estate::Atype.all.each do |atype|
            render partial: 'atype_in_list', locals: {atype: atype}
          end
        end

      end

      column do
        panel 'Рейтинг занятости', class: 'clearfix' do
          render_table_prop_busy_coef
        end
        panel 'Рейтинг занятости в м.кв.', class: 'clearfix' do
          render_table_prop_busy_coef_sq
        end
      end

    end

    if current_admin_user.can_view_statistics?
      section '' do
        columns do
          column do
            panel "10 последних событий изменения статуса площадей (<a class='white_link' href='/admin/sevents'>Просмотреть все</a>)".html_safe do
              render_table_last_sevents
            end
          end
        end
      end
    end

    # section '', if: -> { current_admin_user.email == 'tz007@mail.ru' } do
    #   columns do
    #     column do
    #       panel 'Admin Features', class: 'clearfix' do
    #         render_upload_areas_excel_form
    #       end
    #     end
    #   end
    # end

    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
