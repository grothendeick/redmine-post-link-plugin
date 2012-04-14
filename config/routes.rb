ActionController::Routing::Routes.draw do |map|
  map.connect 'postlink/:action', :controller => 'postlink'
  map.preview_issue '/issues/preview/new/:id', :controller => 'previews', :action => 'issue'
end 
