C80Estate::Engine.routes.draw do
  match '/estate/get_atype_propnames', :to => 'ajax#get_atype_propnames', :via => :post
  match '/estate/areas_ecoef', :to => 'ajax#areas_ecoef', :via => :post
end