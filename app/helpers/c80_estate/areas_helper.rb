module C80Estate
  module AreasHelper

    # выдать html строку, содержащую список характеристик площади
    def smiph_render_all_props(area)

      result = ''

      # area.item_props.each do |prop|
      #   title = prop.prop_name.title
      #   value = prop.value
      #   uom = prop.prop_name.uom.title
      #   result += "<li><span class='ptitle bold'>#{title}</span>: <span class='pvalue'>#{value}</span> <span class='puom'>#{uom}</span></li>"
      # end

      result += "<li><span class='ptitle bold'>Объект недвижимости</span>: <span class='pvalue'>#{area.property.title}</span></li>"
      result += "<li><span class='ptitle bold'>Объём площади</span>: <span class='pvalue'>#{area.square_value}</span> <span class='puom'>м.кв.</span></li>"
      result += "<li><span class='ptitle bold'><abbr title='За м.кв. в месяц'>Цена</abbr></span>: <span class='pvalue'>#{area.price_value} </span> <span class='puom'>руб</span></li>"

      area.atype.prop_names.each do |atype_propname|
          title = atype_propname.title
          if atype_propname.id == 1 || atype_propname.id == 9
            next
          end
          # value = prop.value
          value = '-'
          uom = ''
          if atype_propname.uom.present?
            uom = atype_propname.uom.title
          end
          aip = ItemProp.where(:area_id => area.id).where(:prop_name_id => atype_propname.id)#.first.value
          if aip.count > 0
            value = aip.first.value
          end
          result += "<li><span class='ptitle bold'>#{title}</span>: <span class='pvalue'>#{value}</span> <span class='puom'>#{uom}</span></li>"
      end

      result += "<li><span class='pvalue label label-info'>#{area.atype.title}</span></li>"
      result = "<ul>#{result}</ul>"
      result.html_safe

    end

    # выдать html строку, содержащую список характеристик площади в виде таблицы
    def smiph_render_common_props(area)

      result = ''
      index = 0

      area_item_props = [
          { title: 'ID площади', value: area.id },
          { title: 'Название', value: area.title },
          { title: 'Адрес', value: area.property.address },
          { title: 'Кто создал', value: area.owner.email },
          { title: 'Время создания', value: area.created_at.strftime('%Y/%m/%d %H:%M:%S') },
          { title: 'Время последнего изменения', value: area.updated_at.strftime('%Y/%m/%d %H:%M:%S') },
          { title: 'Кто последний раз вносил изменения', value: area.last_updater },
          { title: 'Ответственный', value: area.assigned_person_title }
      ]

      area_item_props.each do |prop|
        title = prop[:title]
        value = prop[:value]
        result += "<tr class='p#{index % 2}'><td><span class='ptitle medium'>#{title}</span></td> <td><span class='pvalue'>#{value}</span></td></tr>"
        index += 1
      end

      result = "<table>#{result}</table>"
      result.html_safe

    end

    # рендер фотографий при просмотре товара (http://td-forbiz.ru/stroitelnye-materialy/kirpich/1)
    def lh_render_gallery4(area_photos)

      render :partial => "c80_estate/shared/areas/gallery4",
             :locals => {
                 frames: area_photos
             }

    end

    def smiph_render_vendor_logo(area)

      res = ''

      # begin

        # vid = item_as_hash["vendor_id"]
        property = area.property

        if property.plogos.count > 0
          arr = []
          property.plogos.limit(1).each do |pph|
            arr << "<a href='#' class='no-clickable no-outline' title='#{property.title}'><img src='#{ property.logo_path }' alt='#{property.title}'/></a>"
          end
          res = arr.join('').html_safe
        end

      # rescue => e
      #   Rails.logger.debug "<smiph_render_vendor_logo> [ERROR] rescue: #{e}"
      # end

      res.html_safe

    end

  end
end