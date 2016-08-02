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

      result += "<li><span class='ptitle bold'>Объект недвижимости</span>: "
      result += "<a href='/admin/properties/#{area.property.id}'"
      result += "<span class='pvalue'>"
      result += "#{ area.property_title }"
      result += "</a></span></li>"
      # result += "<li><span class='ptitle bold'>Объём площади</span>: <span class='pvalue'>#{area.square_value}</span> <span class='puom'>м.кв.</span></li>"
      # result += "<li><span class='ptitle bold'><abbr title='За м.кв. в месяц'>Цена</abbr></span>: <span class='pvalue'>#{area.price_value} </span> <span class='puom'>руб</span></li>"

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

    # для подкатегории strsubcat сформировать список цен, которые выводятся под картинкой
    def smiph_render_price_props(area)

      result = ""

      # rows = PriceProp.gget_pprops_for_strsubcat(strsubcat_id)
      # rows.each(:as => :hash) do |row|

      rows = [
          {
              title: 'Метраж',
              abbr: 'Объем площади',
              value: area.square_value,
              uom: 'м.кв.',
              css:''
          },
          {
              title: 'Цена',
              abbr: 'За метр квадратный в месяц',
              value: area.price_value,
              uom: 'руб',
              css:''
          },
          {
              title: 'Цена площади',
              abbr: 'Стоимость всей площади в месяц. Число PxS, где P - цена за м.кв. в месяц, S - метраж площади в м.кв.',
              value: area.power_price_value,
              uom: 'руб',
              css:''
          },
          {
              title: '',
              abbr: '',
              value: area.astatus_title,
              uom: '',
              css:"astatus_span #{area.astatus_tag}",
          }
      ]
      rows.each do |row|

        title = row[:title]
        value = row[:value]
        abbr = row[:abbr]
        uom = row[:uom]
        css = row[:css]

        # нормальная цена
        result += "<li class='#{css}'>"
        result += "<p class='ptitle medium'><abbr title='#{abbr}'>#{title}</abbr></p>" # Цена за шт | Цена за м²
        result += "<p><span class='pvalue bold'>#{value}<span> <span class='puom'>#{uom}</span></p>" # 1212,80 руб

        # старая цена

        # if item_as_hash['is_sale'] == 1
        #   if related.present?
        #     related_value = item_as_hash['prop_'+related.to_s]
        #     if related_value.present?
        #       v = related_value.gsub(',', '.')
        #       if v.to_f > 0
        #         result += "<p class='old'><span class='pvalue bold'>#{related_value}</span> <span class='puom'>#{uom}</span></p>" # 1212,80 руб
        #       end
        #     end
        #   end
        # end

        result += '</li>'

      end

      result = "<ul>#{result}</ul>"
      result.html_safe

    end

  end
end