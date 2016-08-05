module C80Estate
  module AppHelper

    include AreasHelper
    include PropertiesHelper

    def render_table_prop_busy_coef(atype_id: nil)
      # Rails.logger.debug "<render_table_prop_busy_coef> atype_id = #{atype_id}"

      props = Property.sorted_chart
      if props.count > 0
        list = []

        props.each do |prop|

          # pp = Pstat.busy_coef(prop_id: prop.id, atype_id: atype_id)
          # Rails.logger.debug "<render_table_prop_busy_coef> pp = #{pp}"
          # busy_coef = pp[:busy_coef]
          # props = pp[:raw_props]

          # фиксируем последнее известное событие Pstat
          # и извлекаем из него уже рассчитанные числа
          pstat = prop.last_known_stats
          if pstat.present? # pstat может не быть у площади, которая была создана во время испытаний с ошибкой
            busy_coef = pstat.coef_busy

            list << {
                id: prop.id,
                title: prop.title,
                busy_coef: "#{busy_coef.to_s(:rounded, :precision => 2)} %",
                props: {
                    all_areas: pstat.free_areas + pstat.busy_areas,
                    free_areas: pstat.free_areas,
                    busy_areas: pstat.busy_areas
                }
            }
            # Rails.logger.debug "<render_table_prop_busy_coef> #{prop.title}"
          end
        end

        render :partial => 'c80_estate/shared/table_properties_coef_busy',
               :locals => {
                   list: list
               }
      end
    end

    def render_table_prop_busy_coef_sq(atype_id: nil)
      # Rails.logger.debug "<render_table_prop_busy_coef> atype_id = #{atype_id}"

      props = Property.sorted_chart
      if props.count > 0
        list = []

        props.each do |prop|

          # pp = Pstat.busy_coef(prop_id: prop.id, atype_id: atype_id)
          # Rails.logger.debug "<render_table_prop_busy_coef> pp = #{pp}"
          # busy_coef = pp[:busy_coef]
          # props = pp[:raw_props]

          # фиксируем последнее известное событие Pstat
          # и извлекаем из него уже рассчитанные числа
          pstat = prop.last_known_stats
          if pstat.present? # pstat может не быть у площади, которая была создана во время испытаний с ошибкой
            busy_coef = pstat.coef_busy_sq

            list << {
                id: prop.id,
                title: prop.title,
                busy_coef: "#{busy_coef.to_s(:rounded, :precision => 2)} %",
                props: {
                    all_areas_sq: pstat.free_areas_sq + pstat.busy_areas_sq,
                    free_areas_sq: pstat.free_areas_sq.to_s(:rounded, :precision => 2),
                    busy_areas_sq: pstat.busy_areas_sq.to_s(:rounded, :precision => 2)
                }
            }
            # Rails.logger.debug "<render_table_prop_busy_coef> #{prop.title}"
          end
        end

        render :partial => 'c80_estate/shared/table_properties_coef_busy_sq',
               :locals => {
                   list: list
               }
      end
    end

    def render_upload_areas_excel_form
      render :partial => 'c80_estate/shared/form_upload_areas_excel'
    end

    def render_show_area(area)

      slug = 'stroitelnye-materialy'
      @page = Page.where(:slug => slug).first

      @item = area #strh_item_get(@sub_cat.id,params[:item_id]) #Item.find(params[:item_id])
      @sub_cat = area.atype #Strsubcat.where(:slug => params[:sub_cat_slug]).first

      # puts "<SiteController.stroitelnye_materialy_item> @item = #{@item}"
      # {"id"=>5, "item_id"=>5, "item_title"=>"Кирпич длинного формата Alt Berlin GS стандарт качества Qbricks",
      # "is_main"=>0, "is_hit"=>1, "is_sale"=>0, "strsubcat_id"=>1, "strsubcat_slug"=>"kirpich",
      # "vendor_id"=>-1,
      # "prop_18"=>"93,98", "prop_19"=>"0", "prop_20"=>"51", "prop_21"=>"0",
      # "prop_23"=>"290 x 90 x 52 мм", "prop_24"=>"Германия", "prop_25"=>"1000",
      # "prop_26"=>"0,10", "prop_27"=>"F300", "prop_28"=>"2,9", "prop_29"=>"чёрный",
      # "prop_30"=>"пустотелый", "prop_31"=>"пластичное формование", "prop_32"=>"шероховатая",
      # "prop_33"=>"2,50", "prop_34"=>"450", "prop_35"=>"длинный, ригельный", "prop_36"=>"Не указан",
      # "prop_37"=>"PR12010-1", "prop_38"=>"NF"}

      # @vparams[:body_class] += ' stroitelnye_materialy_item'

      # add_breadcrumb 'Строительные материалы', '/stroitelnye-materialy', :title => 'Строительные материалы'
      # add_breadcrumb @sub_cat.title, apph_my_url_strsubcat(@sub_cat), :title => @sub_cat.title
      # add_breadcrumb @item["item_title"]

      @vparams = {}
      # @vparams[:page_slug] = 'stroitelnye-materialy' # помогаем слайдеру страницы найти соответствующие картинки
      # @vparams[:sub_cat_slug] = params[:sub_cat_slug]
      # @vparams[:c80_order_form_subj] = "#{root_url}stroitelnye-materialy/#{params[:sub_cat_slug]}/#{params[:item_id]}"
      # @vparams[:c80_order_form_comment_text] = "Заявка на '#{@item["item_title"]}'. Кол-во: "

      # найдём галереи товара
      @vparams[:galleries] = @item.aphotos #Gallery.where_item(params[:item_id])

      render :partial => 'c80_estate/shared/areas/single_area_on_page'
    end

    def render_show_property(property)

      slug = 'stroitelnye-materialy'
      @page = Page.where(:slug => slug).first

      @item = property #strh_item_get(@sub_cat.id,params[:item_id]) #Item.find(params[:item_id])
      # @sub_cat = area.atype #Strsubcat.where(:slug => params[:sub_cat_slug]).first

      # puts "<SiteController.stroitelnye_materialy_item> @item = #{@item}"
      # {"id"=>5, "item_id"=>5, "item_title"=>"Кирпич длинного формата Alt Berlin GS стандарт качества Qbricks",
      # "is_main"=>0, "is_hit"=>1, "is_sale"=>0, "strsubcat_id"=>1, "strsubcat_slug"=>"kirpich",
      # "vendor_id"=>-1,
      # "prop_18"=>"93,98", "prop_19"=>"0", "prop_20"=>"51", "prop_21"=>"0",
      # "prop_23"=>"290 x 90 x 52 мм", "prop_24"=>"Германия", "prop_25"=>"1000",
      # "prop_26"=>"0,10", "prop_27"=>"F300", "prop_28"=>"2,9", "prop_29"=>"чёрный",
      # "prop_30"=>"пустотелый", "prop_31"=>"пластичное формование", "prop_32"=>"шероховатая",
      # "prop_33"=>"2,50", "prop_34"=>"450", "prop_35"=>"длинный, ригельный", "prop_36"=>"Не указан",
      # "prop_37"=>"PR12010-1", "prop_38"=>"NF"}

      # @vparams[:body_class] += ' stroitelnye_materialy_item'

      # add_breadcrumb 'Строительные материалы', '/stroitelnye-materialy', :title => 'Строительные материалы'
      # add_breadcrumb @sub_cat.title, apph_my_url_strsubcat(@sub_cat), :title => @sub_cat.title
      # add_breadcrumb @item["item_title"]

      @vparams = {}
      # @vparams[:page_slug] = 'stroitelnye-materialy' # помогаем слайдеру страницы найти соответствующие картинки
      # @vparams[:sub_cat_slug] = params[:sub_cat_slug]
      # @vparams[:c80_order_form_subj] = "#{root_url}stroitelnye-materialy/#{params[:sub_cat_slug]}/#{params[:item_id]}"
      # @vparams[:c80_order_form_comment_text] = "Заявка на '#{@item["item_title"]}'. Кол-во: "

      # найдём галереи товара
      @vparams[:galleries] = @item.pphotos #Gallery.where_item(params[:item_id])

      render :partial => 'c80_estate/shared/properties/single_property_on_page'
    end

  end
end