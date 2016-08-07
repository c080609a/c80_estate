module C80Estate
  class ItemProp < ActiveRecord::Base

    belongs_to :area
    # belongs_to :property
    belongs_to :prop_name

    before_save :before_save_format_value

    def save(*args)
      super
    rescue ActiveRecord::RecordNotUnique => error
      # post.errors[:base] << "You can only have one photo be your header photo"
      false
    end

    def self.all_uniq_values(prop_name_id)
      r = self.where(prop_name_id: prop_name_id)
          .map { |ip| ip.value.to_i }.uniq
      # Rails.logger.debug("<ItemProp.all_uniq_values> #{prop_name_id}: #{r}")
      r
    end

    private

    def self.capz
      [24, 36, 46]
    end

    def self.uppz
      [27, 37, 38]
    end

    def self.siz
      [23]
    end

    def before_save_format_value

      v = self.value
      uom = prop_name.uom

      # удаляем пробелы в начале и в конце строки
      v = v.strip! || v

      # числовые значения преобразуем в числа
      if uom.present? && uom.is_number

        v = v.gsub(' ', '')
        v = v.gsub(',', '.')
        v = v[/([0-9.]+)/]

        # нечисловые значения: либо capitalize, либо upcase, либо downcase
      else

        if prop_name_id.in?(ItemProp.capz)
          v = v.mb_chars.capitalize.to_s
        elsif prop_name_id.in?(ItemProp.uppz)
          v = v.mb_chars.upcase.to_s
        else
          v = v.mb_chars.downcase.to_s
        end

      end

      if prop_name_id.in?(ItemProp.siz)
        v = v.gsub(',', '.')
        sizes = v.scan(/([0-9,]+)/)
        oum = v.scan(/[мс]*м/)
        v = sizes.join(" x ")
        if oum.count > 0
          v += " #{oum[0]}"
        else
          v += ' мм'
        end
      end


      self.value = v

    end

  end
end