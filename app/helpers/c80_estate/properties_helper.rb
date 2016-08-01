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

      # result += "<li><span class='ptitle bold'>Объём</span>: <span class='pvalue'>#{property.square_value}</span> <span class='puom'>м.кв.</span></li>"
      # result += "<li><span class='ptitle bold'>Доход при 100% занятости</span>: <span class='pvalue'>#{property.power_price_value}</span> <span class='puom'>руб</span></li>"
      # result += "<li><span class='ptitle bold'>Всего площадей</span>: <span class='pvalue'>#{property.areas.all.count}</span></li>"

      result += "<li><span class='ptitle bold'>Свободно площадей</span>: <span class='pvalue'>#{property.areas.free_areas.count}</span></li>"
      result += "<li><span class='ptitle bold'>Занято площадей</span>: <span class='pvalue'>#{property.areas.busy_areas.count}</span></li>"
      result += "<li><span class='ptitle bold'>Свободно метров</span>: <span class='pvalue'>#{property.areas.free_areas_sq.to_s(:rounded, precision: 2)}</span> <span class='puom'>м.кв.</span></li>"
      result += "<li><span class='ptitle bold'>Занято метров</span>: <span class='pvalue'>#{property.areas.busy_areas_sq.to_s(:rounded, precision: 2)}</span> <span class='puom'>м.кв.</span></li>"
      result += '<li style="opacity:0.0">.</li>'
      result += "<li><span style='font-weight:bold;'>Площади объекта по типам:</span></li><ul>"

      Atype.all.each do |atype|
        aa = Area.where(:property_id => property.id).where_atype(atype.id)
        c = aa.count
        if c > 0
          cb = aa.free_areas.count
          result +=
              "<li><span class='ptitle bold'>#{atype.title}</span>: <span class='pvalue'>#{c}</span>
              <abbr title='Свободно'><span class='puom'>(#{cb})</span></abbr></li>"
        end
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
          { title: 'Кто создал', value: property.owner_title },
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

    #
    def ph_render_price_props(property)

      result = ''

      # rows = PriceProp.gget_pprops_for_strsubcat(strsubcat_id)
      # rows.each(:as => :hash) do |row|

      rows = [
          {
              title: 'Метраж',
              abbr: 'Объем площади: сумма по всем площадям объекта',
              value: property.square_value.to_s(:rounded, precision: 2),
              uom: 'м.кв.'
          },
          {
              title: 'Площадей',
              abbr: 'Количество площадей на объекте',
              value: property.areas.count,
              uom: ''
          },
          {
              title: 'Цена объекта',
              abbr: 'Сумма всех цен площадей объекта',
              value: property.power_price_value.to_s(:rounded, precision: 2),
              uom: 'руб'
          }
      ]
      rows.each do |row|

        title = row[:title]
        value = row[:value]
        abbr = row[:abbr]
        uom = row[:uom]

        # нормальная цена
        result += '<li>'
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

    #
    def ph_render_areas_table(property)

      result = '<thead>
                  <tr>
                    <th class="col col-title"><a href="/admin/areas?order=title_desc">Название</a></th>
                    <th class="col col-atype">Тип</th>
                    <th class="col col-abbr_title_abbr"><abbr title="За м.кв. в месяц">Цена м.кв.</abbr></th>
                    <th class="col"><abbr title="Стоимость всей площади в месяц. Число PxS, где P - цена за м.кв. в месяц, S - метраж площади в м.кв.">Цена площади</abbr></th>
                    <th class="col col-">Метраж</th>
                    <th class="col col-astatuses">Статус</th>
                    <th class="col col-assigned_person">Ответственный</th>
                    <th class="col"></th>
                  </tr>
                </thead>'

      result += '<tbody>'
      property.areas.all.each_with_index do |area,index|
        klass = 'odd'
        if index%2 == 0
          klass = 'even'
        end
        result += '<tr>'
        result += "<td>#{ link_to area.title, "/admin/areas/#{area.id}", title: I18n.t("active_admin.view") }</td>"
        result += "<td>#{ area.atype_title }</td>"
        result += "<td style='white-space: nowrap;'>#{area.price_value} руб</td>"
        result += "<td style='white-space: nowrap;'>#{area.power_price_value} руб</td>"
        result += "<td style='white-space: nowrap;'>#{area.square_value} м.кв.</td>"
        result += "<td><span class='status_#{area.astatus_tag}'>#{area.astatus_title}</span></td>"
        result += "<td>#{area.property.assigned_person_title}</td>"
        result += '</tr>'
      end
      result += '</tbody>'

      result = "<table class='sortable index_table index'>#{result}</table>"
      result += "<div class='table_footer'>"
      result += "<span>Количество: #{ property.areas.all.count }</span>"
      result += '</div>'
      result.html_safe
    end

  end
end