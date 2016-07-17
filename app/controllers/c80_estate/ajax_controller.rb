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
      start_date = request.params[:start_date] == "" ? nil:request.params[:start_date]
      end_date = request.params[:end_date] == "" ? nil:request.params[:end_date]

      obj = Sevent.ecoef(area_id: area_id, start_date: start_date, end_date: end_date)

      respond_to do |format|
        format.js { render json: obj, status: :ok }
        # format.json
      end
    end
    
    def properties_busy_coef

      prop_id = request.params[:prop_id] == "" ? nil:request.params[:prop_id]
      start_date = request.params[:start_date] == "" ? nil:request.params[:start_date]
      end_date = request.params[:end_date] == "" ? nil:request.params[:end_date]

      obj = Pstat.busy_coef(prop_id: prop_id, start_date: start_date, end_date: end_date)

      respond_to do |format|
        format.js { render json: obj, status: :ok }
        # format.json
      end

    end

  end
end