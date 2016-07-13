module C80Estate
  class Sevent < ActiveRecord::Base
    belongs_to :area
    belongs_to :atype
    belongs_to :property
    belongs_to :astatus
    belongs_to :auser, :polymorphic => true

=begin
    def self.all_areas
      self.all
    end

    def self.free_areas
      self.joins(:astatuses).where(:c80_estate_astatuses => { tag: 'free'})
    end

    def self.busy_areas
      self.joins(:astatuses).where(:c80_estate_astatuses => { tag: 'busy'})
    end
=end

    def self.ecoef(area_id: nil, prop_id: nil, atype_id: nil, start_date: nil, end_date: nil)
      result = {}

      # unless end_date.present?
      #   end_date = Time.now.utc #.to_s(:db)
      # end
      # unless start_date.present?
      #   if prop_id.present?
      #     start_date =
      #   end
      # end

      # произведём выборку из базы в list согласно параметрам
      list = []

      # если ничего не подано - выбираем всё и считаем среднее
      if area_id.nil? && prop_id.nil? && atype_id.nil? && start_date.nil? && end_date.nil?

        # в result соберём хэш, где ключ - area_id
        # а значение - объект вида {time_free, time_busy} -
        # время, сколько площадь была в аренде или была свободна

        # раскидаем все sevents по area_id related спискам
        self.all.each do |sevent|
          aid = sevent.area_id
          unless result[aid].present?
            result[aid] = {
                time_free: 0,
                time_busy: 0,
                ecoef: 0,
                sevents: []
            }
          end
          result[aid][:sevents] << sevent
        end

        # теперь пробежимся по спискам площадей и посчитаем время
        result.each_key do |area_id|

          # фиксируем area
          a = result[area_id]

          # считаем free busy time
          t = self._calc_busy_time(a)
          a[:time_free] = t[:time_free]
          a[:time_busy] = t[:time_busy]
          a[:ecoef] = t[:ecoef]

        end

        # теперь имеется result в котором посчитаны time_free и time_busy
        # каждой площади
        # пробежимся по нему и посчитаем коэф-ты
        k = 0
        summ = 0
        result.each_key do |area_id|
          a = result[area_id]
          # a[:ecoef] = a[:time_busy] / (a[:time_busy] + a[:time_free])
          Rails.logger.debug "<ecoef> area_id=#{area_id}, time_free=#{a[:time_free]}, time_busy=#{a[:time_busy]}, ecoef=#{a[:ecoef]}"
          k += 1
          summ += a[:ecoef]
        end

        result[:average_value] = sprintf "%.2f%", summ/k*100

      elsif area_id.present?

        t = _calc_busy_time({
                                time_free: 0,
                                time_busy: 0,
                                ecoef: 0,
                                sevents: self.where(:area_id => area_id)
                            })

        result[area_id] = {
            time_free: t[:time_free],
            time_busy: t[:time_busy],
            ecoef: t[:ecoef],
            sevents: self.where(:area_id => area_id)
        }

        result[:average_value] = sprintf "%.2f%", result[area_id][:ecoef]*100

      end

      result

    end

    def area_title
      res = "-"
      if area.present?
        res = area.title
      end
      res
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

    def astatus_title
      res = "-"
      if astatus.present?
        res = astatus.title
      end
      res
    end

    def auser_title
      res = "-"
      if auser.present?
        res = auser.email
      end
      res
    end

    private

    def self._calc_busy_time(a)

      # {
      #     time_free: 0,
      #     time_busy: 0,
      #     ecoef:0,
      #     sevents: []
      # }

      res = {
          time_free: 0,
          time_busy: 0,
          ecoef: 0
      }

      # переберём area related sevents
      a[:sevents].each_with_index do |sevent, index|

        # если это первый элемент (т.е. до меня нет никого)
        if index == 0

          # если это последний элемент - то добавляем, сколько времени площадь в последнем известном статусе ДО текущего момента
        elsif index == a[:sevents].count - 1

          # фиксируем текущее время
          tnow = Time.now
          d = tnow - sevent.created_at

          case sevent.astatus.tag
            when 'free'
              res[:time_free] += d
            when 'busy'
              res[:time_busy] += d
          end

          # если перед элементом есть кто-то
        else

          # фиксируем предыдущий элемент
          prev_sevent = a[:sevents][index-1]

          # и считаем его длительность
          d = sevent.created_at - prev_sevent.created_at

          case prev_sevent.astatus.tag
            when 'free'
              res[:time_free] += d
            when 'busy'
              res[:time_busy] += d
          end
        end
      end

      res[:ecoef] = res[:time_busy] / (res[:time_busy] + res[:time_free])

      res
    end

  end
end