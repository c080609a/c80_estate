module C80Estate
  class AjaxViewController < ActionController::Base

    def table_properties_coef_busy

      @atype_id = request.params[:atype_id] == "" ? nil:request.params[:atype_id]

      respond_to do |format|
        format.js
      end
    end

    def table_properties_coef_busy_sq

      @atype_id = request.params[:atype_id] == "" ? nil:request.params[:atype_id]

      respond_to do |format|
        format.js
      end
    end

  end
end