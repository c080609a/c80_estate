module C80Estate
  class AjaxAreasController < ActionController::Base

    def exel_import

      is_ok = true
      errs = {
          "areas_exel" => [

          ]
      }

      begin
        @import_result = Area.import_excel(params[:file])
      rescue => e
        Rails.logger.debug "ERROR: #{e}"
        errs["areas_exel"].push(e.to_s)
        is_ok = false
      end

      # TODO:: Excel: реализовать вывод тех ошибок, которые возникли при импорте: например: таблица была импортирована за исключением таких-то полей

      respond_to do |format|
        if is_ok
          format.js { render json: errs, status: :ok }
          format.json
          format.html
        else
          format.js { render json: errs, status: :unprocessable_entity }
          format.json
          format.html
        end
      end

    end

  end
end