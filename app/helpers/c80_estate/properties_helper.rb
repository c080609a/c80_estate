module C80Estate
  module PropertiesHelper

    def smiph_render_property_props(property)

      result = ''

      # area.item_props.each do |prop|
      #   title = prop.prop_name.title
      #   value = prop.value
      #   uom = prop.prop_name.uom.title
      #   result += "<li><span class='ptitle bold'>#{title}</span>: <span class='pvalue'>#{value}</span> <span class='puom'>#{uom}</span></li>"
      # end

      result += "<li><span class='ptitle bold'>Объём</span>: <span class='pvalue'>#{property.square_value}</span> <span class='puom'>м.кв.</span></li>"
      result += "<li><span class='ptitle bold'>Доход при 100% занятости</span>: <span class='pvalue'>#{property.power_price_value}</span> <span class='puom'>руб</span></li>"
      result += "<li><span class='ptitle bold'>Всего площадей</span>: <span class='pvalue'>#{property.areas.all.count}</span></li>"
      result += "<li><span class='ptitle bold'>Свободно площадей</span>: <span class='pvalue'>#{property.areas.free_areas.count}</span></li>"
      result += "<li><span class='ptitle bold'>Занято площадей</span>: <span class='pvalue'>#{property.areas.busy_areas.count}</span></li>"
      result += "<li><span class='ptitle bold'>Свободно метров</span>: <span class='pvalue'>#{property.areas.free_areas_sq}</span> <span class='puom'>м.кв.</span></li>"
      result += "<li><span class='ptitle bold'>Занято метров</span>: <span class='pvalue'>#{property.areas.busy_areas_sq}</span> <span class='puom'>м.кв.</span></li>"
      result += "<li><span style='font-weight:bold;'>Площади объекта по типам:</span></li><ul>"

      Atype.all.each do |atype|
        aa = Area.where_atype(atype.id)
        c = aa.count
        cb = aa.busy_areas.count
        result +=
            "<li><span class='ptitle bold'>#{atype.title}</span>: <span class='pvalue'>#{c}</span>
              <abbr title='Занятых'><span class='puom'>(#{cb})</span></abbr></li>"
      end

      result = "<ul>#{result}</ul></ul>"
      result.html_safe

    end

    def ph_render_tech_props(property)

      result = ''
      index = 0

      area_item_props = [
          { title: 'ID объекта', value: property.id },
          { title: 'Название', value: property.title },
          { title: 'Адрес', value: property.address },
          { title: 'Кто создал', value: property.owner.email },
          { title: 'Время создания', value: property.created_at.strftime('%Y/%m/%d %H:%M:%S') },
          { title: 'Время последнего изменения', value: property.updated_at.strftime('%Y/%m/%d %H:%M:%S') },
          { title: 'Кто последний раз вносил изменения', value: property.last_updater },
          { title: 'Ответственный', value: property.assigned_person_title }
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

  end
end