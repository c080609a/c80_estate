module C80Estate
  module AppHelper

    def render_table_prop_busy_coef(atype_id: nil)
      # Rails.logger.debug "<render_table_prop_busy_coef> atype_id = #{atype_id}"

      props = Property.all
      if props.count > 0
        list = []

        props.all.each do |prop|
          pp = Pstat.busy_coef(prop_id: prop.id, atype_id: atype_id)
          # Rails.logger.debug "<render_table_prop_busy_coef> pp = #{pp}"
          busy_coef = pp[:busy_coef]
          props = pp[:raw_props]
          list << {
              title: prop.title,
              busy_coef: busy_coef,
              props: props
          }
          # Rails.logger.debug "<render_table_prop_busy_coef> #{prop.title}"
        end

        render :partial => 'c80_estate/shared/table_properties_coef_busy',
               :locals => {
                   list: list
               }
      end
    end

    def render_table_prop_busy_coef_sq(atype_id: nil)
      # Rails.logger.debug "<render_table_prop_busy_coef_sq> atype_id = #{atype_id}"

      props = Property.all

      if props.count > 0
        list = []

        props.all.each do |prop|
          pp = Pstat.busy_coef(prop_id: prop.id, atype_id: atype_id)
          # Rails.logger.debug "<render_table_prop_busy_coef> pp = #{pp}"
          busy_coef_sq = pp[:busy_coef_sq]
          props = pp[:raw_props_sq]
          list << {
              title: prop.title,
              busy_coef: busy_coef_sq,
              props: props
          }
          # Rails.logger.debug "<render_table_prop_busy_coef> #{prop.title}"
        end

        render :partial => 'c80_estate/shared/table_properties_coef_busy_sq',
               :locals => {
                   list: list
               }
      end
    end

  end
end