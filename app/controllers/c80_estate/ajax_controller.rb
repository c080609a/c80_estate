module C80Estate
  class AjaxController < ActionController::Base

    def get_atype_propnames

      atype_id = request.params[:atype_id]
      obj = Atype.get_propnames(atype_id)

      respond_to do |format|
        format.js { render json: obj, status: :ok }
        # format.json
      end

    end

    def areas_ecoef

      area_id = request.params[:area_id] == "" ? nil:request.params[:area_id]

      obj = Sevent.ecoef(area_id: area_id)

      respond_to do |format|
        format.js { render json: obj, status: :ok }
        # format.json
      end
    end

  end
end