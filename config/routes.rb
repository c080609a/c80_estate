C80Estate::Engine.routes.draw do
  match '/estate/get_atype_propnames', :to => 'ajax#get_atype_propnames', :via => :post
end