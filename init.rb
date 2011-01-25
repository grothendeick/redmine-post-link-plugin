require 'redmine'

Redmine::Plugin.register :redmine_postlink_plugin do
  name 'Redmine submit issue through GET plugin'
  author 'Piotr Duda'
  description 'This plugin allows project testers to create issues through a GET URL'
  version '0.9.0'

  project_module :issues_through_get do
    permission :postlink, {:postlink => :new }, :require => :member
  end
end
