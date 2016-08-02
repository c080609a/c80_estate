C80Estate::Engine.routes.draw do
  match '/estate/get_atype_propnames', :to => 'ajax#get_atype_propnames', :via => :post
  match '/estate/areas_ecoef', :to => 'ajax#areas_ecoef', :via => :post
  match '/estate/properties_busy_coef', :to => 'ajax#properties_busy_coef', :via => :post
  match '/estate/can_view_statistics', :to => 'ajax#can_view_statistics', :via => :post

  match '/estate/table_properties_coef_busy', :to => 'ajax_view#table_properties_coef_busy', :via => :post
  match '/estate/table_properties_coef_busy_sq', :to => 'ajax_view#table_properties_coef_busy_sq', :via => :post

  match "/estate/areas_import_exel", :to => "ajax_areas#exel_import", via: :post

end