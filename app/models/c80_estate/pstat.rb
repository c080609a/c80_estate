module C80Estate
  class Pstat < ActiveRecord::Base

    belongs_to :property
    belongs_to :atype
    belongs_to :sevent

    # nil, если это запись с общими данными, а не astatus related запись
    # (добавлена только для того, чтобы можно было :dependend => :destroy)
    belongs_to :parent, :class_name => 'C80Estate::Pstat'
    has_many :pstats, :foreign_key => 'parent_id', :dependent => :destroy

    scope :ordered_by_created_at, -> { order(created_at: :asc) }

    # рассчитаем коэф-ты занятости
    before_create :calc_busy_coefs

    # сгенерим atype related записи
    after_create :generate_atype_pstats

    def self.busy_coef(prop_id: nil, atype_id: nil, start_date: nil, end_date: nil)
      # start_date: строка вида 2015-12-12
      # Rails.logger.debug "<Pstat.busy_coef> prop_id = #{prop_id}, atype_id = #{atype_id}"
      result = {}

      # обозначим диапазон фильтрации
      first_created_at = Time.at(self.first.created_at)
      time_now = Time.now

      # если ничего не подано - просто выберем все занятые площади и поделим на все известные площади
      if prop_id.nil? && atype_id.nil?

        # prepare

        tcut = _calc_time_cut(first_created_at, time_now, start_date, end_date)

        ddd = '-'
        if self.count > 0
          ddd = tcut[:used_start_date_str] #Time.at(self.first.created_at).strftime('%Y/%m/%d')
        end

        pstats = self.where("created_at BETWEEN ? AND ?", tcut[:used_start_date], tcut[:used_end_date])

        # если в этот промежуток небыло событий - значит промежуток целиком попал в какое-то событие
        # найдем его
        # заодно поднимем вспомогательный флаг, который обработаем во view
        mark_whole = false
        if pstats.count == 0
          pstats = [self.where(:property_id => prop_id).where("created_at < ?", tcut[:used_start_date]).last]
          mark_whole = true
          # sevents.each do |se|
          #   Rails.logger.debug "\t\t\t #{used_start_date - se.created_at}"
          # end
        end

        # Занятость

        free_areas_atnow = pstats.where(:atype_id => nil).last.free_areas
        busy_areas_atnow = pstats.where(:atype_id => nil).last.busy_areas
        graph_data = _parse_for_js_dynamic_graph_canvasjs(pstats.where(:atype_id => nil).ordered_by_created_at)

        # защищаемся от деления на ноль
        if free_areas_atnow + busy_areas_atnow == 0
          bcoef = 0.0
        else
          bcoef = busy_areas_atnow*1.0 / (free_areas_atnow + busy_areas_atnow) * 100.0
        end

        # all_areas_count = Area.all.count
        # free_areas_count = Area.free_areas.count
        # busy_areas_count = Area.busy_areas.count

        result[:busy_coef] = sprintf "%.2f%", bcoef
        result[:comment] = "<abbr title='Период рассчёта занятости'>C #{ddd} по #{ tcut[:used_end_date_str] }</abbr>"
        result[:abbr] = 'Показана занятость для ВСЕХ площадей ВСЕХ объектов недвижимости за указанный период'
        result[:props] = [
            {tag: 'all_areas_count', val: "Площадей всего: #{free_areas_atnow + busy_areas_atnow}"},
            {tag: 'free_areas_count', val: "Площадей свободно: #{free_areas_atnow}"},
            {tag: 'busy_areas_count', val: "Площадей занято: #{busy_areas_atnow}"}
        ]
        result[:raw_props] = {}
        result[:raw_props][:all_areas_count] = free_areas_atnow + busy_areas_atnow
        result[:raw_props][:free_areas_count] = free_areas_atnow
        result[:raw_props][:busy_areas_atnow] = busy_areas_atnow
        result[:graph_dynamic] = graph_data

        # Rails.logger.debug "<Pstat.busy_coef> busy_areas_count = #{ busy_areas_count }"
        # Rails.logger.debug "<Pstat.busy_coef> all_areas_count = #{ all_areas_count }"
        # Rails.logger.debug "<Pstat.busy_coef> result[:busy_coef] = #{ result[:busy_coef] }"

        # Занятость в метрах

        free_areas_atnow_sq = pstats.where(:atype_id => nil).last.free_areas_sq
        busy_areas_atnow_sq = pstats.where(:atype_id => nil).last.busy_areas_sq
        graph_data_sq = _parse_for_js_dynamic_graph3_canvasjs(pstats.where(:atype_id => nil).ordered_by_created_at)

        # защищаемся от деления на ноль
        if busy_areas_atnow_sq + free_areas_atnow_sq == 0
          bcoef_sq = 0.0
        else
          bcoef_sq = busy_areas_atnow_sq*1.0/(busy_areas_atnow_sq + free_areas_atnow_sq)*100.0
        end

        result[:busy_coef_sq] = sprintf "%.2f%", bcoef_sq
        result[:comment_sq] = "<abbr title='Период рассчёта занятости в МЕТРАХ КВ'>C #{tcut[:used_start_date_str]} по #{tcut[:used_end_date_str]}</abbr>"
        result[:abbr_sq] = 'Занятость объекта в МЕТРАХ за указанный период: число b/N, где b - кол-во свободных МЕТРОВ, N - всего МЕТРОВ КВ'
        result[:props_sq] = [
            {tag: 'all_areas_count_sq', val: "Кв.м. всего: #{busy_areas_atnow_sq + free_areas_atnow_sq}"},
            {tag: 'free_areas_count_sq', val: "Свободных: #{free_areas_atnow_sq}"},
            {tag: 'busy_areas_count_sq', val: "Занятых: #{busy_areas_atnow_sq}"}
        ]
        result[:graph_dynamic_sq] = graph_data_sq

        # common

        result[:title] = 'Статистика - Все объекты недвижимости'

        # если фильтруем по property
      elsif prop_id.present?

        # фиксируем property
        property = Property.find(prop_id)

        # работаем с ней, если только есть площади
        if property.areas.count > 0

          # обозначим диапазон фильтрации
          area_created_at = Time.at(property.areas.first.created_at)
          time_now = Time.now
          # Rails.logger.debug("area_created_at = #{area_created_at}")
          # Rails.logger.debug("time_now = #{time_now}")

          # если подана нижняя граница диапазона и она позже, чем время создания самой первой площади объекта,
          # выравниваем период рассчета коэф-та по этой нижней границе диапазона
          if start_date.present?
            start_date_tt = Time.parse(start_date)
            if start_date_tt > area_created_at
              used_start_date = start_date_tt
              # Rails.logger.debug("start_date: используем аргумент: #{start_date_tt}")
            else
              used_start_date = area_created_at
              # Rails.logger.debug("start_date: используем время рождения Площади: #{area_created_at}")
            end
          else
            used_start_date = area_created_at
            # Rails.logger.debug("start_date: используем время рождения Площади: #{area_created_at}")
          end
          used_start_date_str = used_start_date.strftime('%Y/%m/%d')

          if end_date.present?
            end_date_tt = Time.parse(end_date)
            if end_date < time_now
              used_end_date = end_date_tt
              Rails.logger.debug("end_date: используем аргумент: #{end_date_tt}")
            else
              used_end_date = time_now
              Rails.logger.debug("end_date: используем текущее время")
            end
          else
            used_end_date = time_now
            Rails.logger.debug("end_date: используем текущее время")
          end
          used_end_date_str = used_end_date.strftime('%Y/%m/%d')

          # Rails.logger.debug("start_date = #{start_date}; end_date = #{end_date}; used_start_date = #{used_start_date}; used_end_date = #{used_end_date}")
          # sevents = self.where(:area_id => area_id).where(:created_at => used_start_date..used_end_date)
          pstats = self.where(:property_id => prop_id)
                       .where("created_at BETWEEN ? AND ?", used_start_date, used_end_date)

          if atype_id.present?
            pstats = pstats.where(:atype_id => atype_id)
          end

          # если в этот промежуток небыло событий - значит промежуток целиком попал в какое-то событие
          # найдем его
          # заодно поднимем вспомогательный флаг, который обработаем во view
          mark_whole = false
          if pstats.count == 0
            pstats = [self.where(:property_id => prop_id).where("created_at < ?", used_start_date).last]
            mark_whole = true
            # sevents.each do |se|
            #   Rails.logger.debug "\t\t\t #{used_start_date - se.created_at}"
            # end
          end

          # Занятость -----

          # если сортируем по типу, то берём последнюю запись,
          # иначе - берём последнюю запись с общими данными
          if atype_id.nil?
            free_areas_atnow = pstats.where(:atype_id => nil).last.free_areas
            busy_areas_atnow = pstats.where(:atype_id => nil).last.busy_areas
            graph_data = _parse_for_js_dynamic_graph_canvasjs(pstats.where(:atype_id => nil).ordered_by_created_at)
          else
            free_areas_atnow = pstats.last.free_areas
            busy_areas_atnow = pstats.last.busy_areas
            graph_data = _parse_for_js_dynamic_graph_canvasjs(pstats.ordered_by_created_at)
          end

          # Rails.logger.debug("\t\t atype_id = #{atype_id}")
          # Rails.logger.debug("\t\t free_areas_atnow = #{free_areas_atnow}")
          # Rails.logger.debug("\t\t busy_areas_atnow = #{busy_areas_atnow}")

          # защищаемся от деления на ноль
          if free_areas_atnow + busy_areas_atnow == 0
            bcoef = 0.0
          else
            bcoef = busy_areas_atnow*1.0 / (free_areas_atnow + busy_areas_atnow) * 100.0
          end

          result[:busy_coef] = sprintf "%.2f%", bcoef
          result[:comment] = "<abbr title='Период рассчёта занятости'>C #{used_start_date_str} по #{used_end_date_str}</abbr>"
          result[:abbr] = 'Занятость объекта за указанный период: число b/N, где b - кол-во свободных, N - всего площадей'

          result[:raw_props] = {}
          result[:raw_props][:all_areas_count] = free_areas_atnow + busy_areas_atnow
          result[:raw_props][:free_areas_count] = free_areas_atnow
          result[:raw_props][:busy_areas_atnow] = busy_areas_atnow

          # Занятость в метрах ------

          if atype_id.nil?
            free_areas_atnow_sq = pstats.where(:atype_id => nil).last.free_areas_sq
            busy_areas_atnow_sq = pstats.where(:atype_id => nil).last.busy_areas_sq
            graph_data_sq = _parse_for_js_dynamic_graph3_canvasjs(pstats.where(:atype_id => nil).ordered_by_created_at)
          else
            free_areas_atnow_sq = pstats.last.free_areas_sq
            busy_areas_atnow_sq = pstats.last.busy_areas_sq
            graph_data_sq = _parse_for_js_dynamic_graph3_canvasjs(pstats.ordered_by_created_at)
          end

          # защищаемся от деления на ноль
          if busy_areas_atnow_sq + free_areas_atnow_sq == 0
            bcoef_sq = 0.0
          else
            bcoef_sq = busy_areas_atnow_sq*1.0/(busy_areas_atnow_sq + free_areas_atnow_sq)*100.0
          end

          result[:busy_coef_sq] = sprintf "%.2f%", bcoef_sq
          result[:comment_sq] = "<abbr title='Период рассчёта занятости в МЕТРАХ КВ'>C #{used_start_date_str} по #{used_end_date_str}</abbr>"
          result[:abbr_sq] = 'Занятость объекта в МЕТРАХ за указанный период: число b/N, где b - кол-во свободных МЕТРОВ, N - всего МЕТРОВ КВ'
          result[:props_sq] = [
              {tag: 'all_areas_count_sq', val: "Кв.м. всего: #{busy_areas_atnow_sq + free_areas_atnow_sq}"},
              {tag: 'free_areas_count_sq', val: "Свободных: #{free_areas_atnow_sq}"},
              {tag: 'busy_areas_count_sq', val: "Занятых: #{busy_areas_atnow_sq}"}
          ]

          # common

          result[:title] = "Статистика - Объект - #{property.title}"
          # result[:graph] = _parse_for_js_radial_graph(free_areas_atnow,busy_areas_atnow)
          result[:graph_dynamic] = graph_data
          result[:graph_dynamic_sq] = graph_data_sq

          # if atype_id.present?
          #   result[:title] += " (#{Atype.find(atype_id).title})"
          # end

          dc_str = property.areas.first.created_at.in_time_zone('Moscow').strftime('%Y/%m/%d')
          dc_abbr = 'За дату создания объекта недвижимости при рассчетах берётся дата создания первой площади объекта'

          result[:props] = [
              {tag: 'title', val: "#{property.title}"},
              {tag: 'born_date', val: "<abbr title='#{dc_abbr}'>Дата создания: #{dc_str}"},
              {tag: 'all_areas_count', val: "<abbr title='В конце указанного периода'>Площадей всего</abbr>: #{ free_areas_atnow + busy_areas_atnow }"},
              {tag: 'free_areas_count', val: "<abbr title='В конце указанного периода'>Свободных площадей</abbr>: #{ free_areas_atnow }"},
              {tag: 'busy_areas_count', val: "<abbr title='В конце указанного периода'>Занятых площадей</abbr>: #{ busy_areas_atnow }"}
          ]

          if atype_id.present?
            result[:props] << {tag: 'atype_filter', val: "Фильтр по типу площади: #{ Atype.find(atype_id).title }"}
          end

        else
          result[:props] = [
              {tag: 'title', val: "#{property.title} не имеет площадей"}
          ]
        end

      elsif atype_id.present?

        # обозначим диапазон фильтрации
        first_created_at = Time.at(self.first.created_at)
        time_now = Time.now

        # если подана нижняя граница диапазона и она позже, чем время создания самой первой площади объекта,
        # выравниваем период рассчета коэф-та по этой нижней границе диапазона
        if start_date.present?
          start_date_tt = Time.parse(start_date)
          if start_date_tt > first_created_at
            used_start_date = start_date_tt
            # Rails.logger.debug("start_date: используем аргумент: #{start_date_tt}")
          else
            used_start_date = first_created_at
            # Rails.logger.debug("start_date: используем время рождения Площади: #{area_created_at}")
          end
        else
          used_start_date = first_created_at
          # Rails.logger.debug("start_date: используем время рождения Площади: #{area_created_at}")
        end
        used_start_date_str = used_start_date.strftime('%Y/%m/%d')

        if end_date.present?
          end_date_tt = Time.parse(end_date)
          if end_date < time_now
            used_end_date = end_date_tt
            # Rails.logger.debug("end_date: используем аргумент: #{end_date_tt}")
          else
            used_end_date = time_now
            # Rails.logger.debug("end_date: используем текущее время")
          end
        else
          used_end_date = time_now
          # Rails.logger.debug("end_date: используем текущее время")
        end
        used_end_date_str = used_end_date.strftime('%Y/%m/%d')

        # Rails.logger.debug("start_date = #{start_date}; end_date = #{end_date}; used_start_date = #{used_start_date}; used_end_date = #{used_end_date}")
        # sevents = self.where(:area_id => area_id).where(:created_at => used_start_date..used_end_date)
        pstats = self.where(:atype_id => atype_id)
                     .where("created_at BETWEEN ? AND ?", used_start_date, used_end_date)


        # если в этот промежуток небыло событий - значит промежуток целиком попал в какое-то событие
        # найдем его
        # заодно поднимем вспомогательный флаг, который обработаем во view
        mark_whole = false
        if pstats.count == 0
          pstats = [self.where(:atype_id => atype_id).where("created_at < ?", used_start_date).last]
          mark_whole = true
          # sevents.each do |se|
          #   Rails.logger.debug "\t\t\t #{used_start_date - se.created_at}"
          # end
        end

        # Занятость

        free_areas_atnow = pstats.last.free_areas
        busy_areas_atnow = pstats.last.busy_areas
        graph_data = _parse_for_js_dynamic_graph_canvasjs(pstats.ordered_by_created_at)

        # Rails.logger.debug("\t\t atype_id = #{atype_id}")
        # Rails.logger.debug("\t\t free_areas_atnow = #{free_areas_atnow}")
        # Rails.logger.debug("\t\t busy_areas_atnow = #{busy_areas_atnow}")

        # защищаемся от деления на ноль
        if free_areas_atnow + busy_areas_atnow == 0
          bcoef = 0.0
        else
          bcoef = busy_areas_atnow*1.0 / (free_areas_atnow + busy_areas_atnow) * 100.0
        end

        result[:busy_coef] = sprintf "%.2f%", bcoef
        result[:comment] = "<abbr title='Период рассчёта занятости'>C #{used_start_date_str} по #{used_end_date_str}</abbr>"
        result[:abbr] = 'Занятость объекта за указанный период: число b/N, где b - кол-во свободных, N - всего площадей'

        result[:raw_props] = {}
        result[:raw_props][:all_areas_count] = free_areas_atnow + busy_areas_atnow
        result[:raw_props][:free_areas_count] = free_areas_atnow
        result[:raw_props][:busy_areas_atnow] = busy_areas_atnow

        # Занятость в метрах

        free_areas_atnow_sq = pstats.last.free_areas_sq
        busy_areas_atnow_sq = pstats.last.busy_areas_sq
        graph_data_sq = _parse_for_js_dynamic_graph3_canvasjs(pstats.ordered_by_created_at)

        # защищаемся от деления на ноль
        if busy_areas_atnow_sq + free_areas_atnow_sq == 0
          bcoef_sq = 0.0
        else
          bcoef_sq = busy_areas_atnow_sq*1.0/(busy_areas_atnow_sq + free_areas_atnow_sq)*100.0
        end

        result[:busy_coef_sq] = sprintf "%.2f%", bcoef_sq
        result[:comment_sq] = "<abbr title='Период рассчёта занятости в МЕТРАХ КВ'>C #{used_start_date_str} по #{used_end_date_str}</abbr>"
        result[:abbr_sq] = 'Занятость объекта в МЕТРАХ за указанный период: число b/N, где b - кол-во свободных МЕТРОВ, N - всего МЕТРОВ КВ'
        result[:props_sq] = [
            {tag: 'all_areas_count_sq', val: "Кв.м. всего: #{busy_areas_atnow_sq + free_areas_atnow_sq}"},
            {tag: 'free_areas_count_sq', val: "Свободных: #{free_areas_atnow_sq}"},
            {tag: 'busy_areas_count_sq', val: "Занятых: #{busy_areas_atnow_sq}"}
        ]

        # common

        result[:title] = "Статистика - Объекты - Фильтр по типу площади '#{ Atype.find(atype_id).title }'"
        # result[:graph] = _parse_for_js_radial_graph(free_areas_atnow,busy_areas_atnow)
        result[:graph_dynamic] = graph_data
        result[:graph_dynamic_sq] = graph_data_sq

        # if atype_id.present?
        #   result[:title] += " (#{Atype.find(atype_id).title})"
        # end

        dc_str = self.first.created_at.in_time_zone('Moscow').strftime('%Y/%m/%d')
        dc_abbr = 'За дату создания объекта недвижимости при рассчетах берётся дата создания первой площади объекта'

        result[:props] = [
            {tag: 'title', val: "Фильтр по типу площади: #{ Atype.find(atype_id).title }"},
            # {tag: 'born_date', val: "<abbr title='#{dc_abbr}'>Дата создания: #{dc_str}"},
            {tag: 'all_areas_count', val: "<abbr title='В конце указанного периода'>Площадей всего</abbr>: #{ free_areas_atnow + busy_areas_atnow }"},
            {tag: 'free_areas_count', val: "<abbr title='В конце указанного периода'>Свободных площадей</abbr>: #{ free_areas_atnow }"},
            {tag: 'busy_areas_count', val: "<abbr title='В конце указанного периода'>Занятых площадей</abbr>: #{ busy_areas_atnow }"}
        ]

        # Rails.logger.debug "result ============= #{result}"

      end

      result

    end

    def atype_title
      res = "-"
      if atype.present?
        res = atype.title
      end
      res
    end

    def property_title
      res = "-"
      if property.present?
        res = property.title
      end
      res
    end

    private

    # Когда создаётся запись, посчитаем коэф-ты
    def calc_busy_coefs
      if self.property.areas.count > 0

        # здесь считаем коэф-ты только для `записей с общими данными`
        if self.atype.nil?

          self.free_areas = self.property.areas.free_areas.count
          self.busy_areas = self.property.areas.busy_areas.count
          self.coef_busy = self.busy_areas*1.0 / (self.free_areas + self.busy_areas) * 100.0

          self.free_areas_sq = self.property.areas.free_areas_sq
          self.busy_areas_sq = self.property.areas.busy_areas_sq
          self.coef_busy_sq = self.busy_areas_sq*1.0 / (self.free_areas_sq + self.busy_areas_sq) * 100.0

          # здесь считаем коэф-ты для 'atype related записей'
        else
          self.free_areas = self.property.areas.where(:atype_id => self.atype.id).free_areas.count
          self.busy_areas = self.property.areas.where(:atype_id => self.atype.id).busy_areas.count
          self.coef_busy = (self.free_areas + self.busy_areas == 0) ? 0 : self.busy_areas*1.0 / (self.free_areas + self.busy_areas) * 100.0

          self.free_areas_sq = self.property.areas.where(:atype_id => self.atype.id).free_areas_sq
          self.busy_areas_sq = self.property.areas.where(:atype_id => self.atype.id).busy_areas_sq
          self.coef_busy_sq = (self.free_areas_sq + self.busy_areas_sq == 0) ? 0 : self.busy_areas_sq*1.0 / (self.free_areas_sq + self.busy_areas_sq) * 100.0
        end
      end
    end

    # Когда создаётся `запись с общими данными` в таблице 'pstats', автоматически
    # создаются `atype related записи` в кол-ве N шт с данными по каждому типу площади
    # с такой же датой created_at
    def generate_atype_pstats

      # генерим только для `записей с общими данными`
      if self.atype.nil?

        # перебираем все типы
        atypes = Atype.all
        atypes.each do |atype|

          # генерим atype related pstats, связываем их с Родителем
          Pstat.create!({
                            atype_id: atype.id,
                            property_id: self.property.id,
                            sevent_id: self.sevent.id,
                            created_at: self.created_at,
                            parent_id: self.id
                        })

        end

      end
    end

    def self._parse_for_js_radial_graph(free_areas_atnow, busy_areas_atnow)
      # res = [
      #     ['Year', 'Sales', 'Expenses'],
      #     ['2013',  1000,      400],
      #     ['2014',  1170,      460],
      #     ['2015',  660,       1120],
      #     ['2016/12/12',  1030,      540]
      #
      # ]
      # [
      #     ['', ''],
      #     ['Свободно',     11],
      #     ['Занято',      2]
      # ]

      res = [['', '']]
      res << ['Свободно', free_areas_atnow]
      res << ['Занято', busy_areas_atnow]
      Rails.logger.debug "<_parse_for_js_radial_graph> res: #{res}"
      res

    end

    def self._parse_for_js_dynamic_graph_chartjs(pstats)

      # res = {
      #     labels: ['2016/12/22',...]
      #     points: [12,13,...]
      # }

      res = {
          labels: [],
          points: []
      }
      pstats.each do |pstat|
        label = pstat.created_at.strftime('%Y/%m/%d')
        point = pstat.coef_busy
        res[:labels] << label
        res[:points] << point
        Rails.logger.debug "<_parse_for_js_dynamic_graph_chartjs> label = #{label}, point = #{point}"
      end
      res

    end

    def self._parse_for_js_dynamic_graph_google_charts(pstats)
      # res = [
      #     ['Year', 'Sales', 'Expenses'],
      #     ['2013',  1000,      400],
      #     ['2014',  1170,      460],
      #     ['2015',  660,       1120],
      #     ['2016/12/12',  1030,      540]
      # ]

      res = []
      pstats.each do |pstat|
        res << [pstat.created_at.strftime('%Y/%m/%d'), pstat.coef_busy]
      end
      res

    end

    def self._parse_for_js_dynamic_graph_canvasjs(pstats)
      # res: [
      #     {
      #         year
      #         month
      #         day
      #         val
      #     }
      # ]

      res = []

      pstats.each do |pstat|

        res << {
            year: pstat.created_at.strftime('%Y'),
            month: pstat.created_at.strftime('%m').to_i-1,
            day: pstat.created_at.strftime('%d'),
            val: pstat.coef_busy
        }

      end

      Rails.logger.debug "<Pstat.parse_for_js_graph> res = #{res}"
      res
    end

    def self._parse_for_js_dynamic_graph3_canvasjs(pstats)
      # res: [
      #     {
      #         year
      #         month
      #         day
      #         val
      #     }
      # ]

      res = []

      pstats.each do |pstat|

        res << {
            year: pstat.created_at.strftime('%Y'),
            month: pstat.created_at.strftime('%m').to_i-1,
            day: pstat.created_at.strftime('%d'),
            val: pstat.coef_busy_sq
        }
      end
      res
    end

    def self._calc_time_cut(first_created_at, time_now, start_date, end_date)

      # если подана нижняя граница диапазона и она позже, чем время создания самой первой площади объекта,
      # выравниваем период рассчета коэф-та по этой нижней границе диапазона
      if start_date.present?
        start_date_tt = Time.parse(start_date)
        if start_date_tt > first_created_at
          used_start_date = start_date_tt
          # Rails.logger.debug("1: start_date: используем аргумент: #{start_date_tt} (first_created_at = #{first_created_at})")
        else
          used_start_date = first_created_at
          # Rails.logger.debug("2: start_date: используем first_created_at: #{first_created_at}")
        end
      else
        used_start_date = first_created_at
        # Rails.logger.debug("3: start_date: используем first_created_at: #{first_created_at} (start_date = #{start_date})")
      end
      used_start_date_str = used_start_date.strftime('%Y/%m/%d')

      if end_date.present?
        end_date_tt = Time.parse(end_date)
        if end_date < time_now
          used_end_date = end_date_tt
          # Rails.logger.debug("end_date: используем аргумент: #{end_date_tt}")
        else
          used_end_date = time_now
          # Rails.logger.debug("end_date: используем текущее время")
        end
      else
        used_end_date = time_now
        # Rails.logger.debug("end_date: используем текущее время")
      end
      used_end_date_str = used_end_date.strftime('%Y/%m/%d')

      {
          used_start_date: used_start_date,
          used_start_date_str: used_start_date_str,
          used_end_date: used_end_date,
          used_end_date_str: used_end_date_str
      }

    end

  end
end