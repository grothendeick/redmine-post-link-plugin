# Redmine - project management software
# Copyright (C) 2006-2008  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class PostlinkController < ApplicationController
  unloadable
  menu_item :post_issue, :only => :new
  default_search_scope :issues
  
  before_filter :find_project, :only => :new
  before_filter :check_for_default_issue_status, :only => :new
  before_filter :build_new_issue_from_params, :only => :new

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid
  
  helper :projects
  include ProjectsHelper   
  helper :custom_fields
  include CustomFieldsHelper
  helper :issue_relations
  include IssueRelationsHelper
  helper :watchers
  include WatchersHelper
  helper :attachments
  include AttachmentsHelper
  helper :queries
  include QueriesHelper
  helper :repositories
  include RepositoriesHelper
  helper :sort
  include SortHelper
  include IssuesHelper

  def index
    render_404
  end

  # Add a new issue
  # The new issue will be created from an existing one if copy_from parameter is given
  def new
    @issue = Issue.new
    @issue.subject = params[:subject]
    @issue.description = params[:description]
    @issue.project = Project.find_by_identifier(params[:project_id])
    @issue.assigned_to_id = User.find_by_mail(params[:email]).id
    @issue.start_date =Time.now.localtime.strftime("%Y-%m-%d")

    respond_to do |format|
      format.html { render :action => 'new', :layout => !request.xhr? }
      format.js { render :partial => 'attributes' }
    end
  rescue RuntimeError
    render_404
  end

private

  def find_project
    project_id = (params[:issue] && params[:issue][:project_id]) || params[:project_id]
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  # Used by #edit and #update to set some common instance variables
  # from the params
  # TODO: Refactor, not everything in here is needed by #edit
  def update_issue_from_params
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    @priorities = IssuePriority.all
    @edit_allowed = User.current.allowed_to?(:edit_issues, @project)
    @time_entry = TimeEntry.new
    @time_entry.attributes = params[:time_entry]
    
    @notes = params[:notes] || (params[:issue].present? ? params[:issue][:notes] : nil)
    @issue.init_journal(User.current, @notes)
    @issue.safe_attributes = params[:issue]
  end

  # TODO: Refactor, lots of extra code in here
  # TODO: Changing tracker on an existing issue should not trigger this
  def build_new_issue_from_params
    if params[:id].blank?
      @issue = Issue.new
      @issue.copy_from(params[:copy_from]) if params[:copy_from]
      @issue.project = @project
    else
      @issue = @project.issues.visible.find(params[:id])
    end
    
    @issue.project = @project
    # Tracker must be set before custom field values
    @issue.tracker ||= @project.trackers.find((params[:issue] && params[:issue][:tracker_id]) || params[:tracker_id] || :first)
    if @issue.tracker.nil?
      render_error l(:error_no_tracker_in_project)
      return false
    end
    @issue.start_date ||= Date.today
    if params[:issue].is_a?(Hash)
      @issue.safe_attributes = params[:issue]
      if User.current.allowed_to?(:add_issue_watchers, @project) && @issue.new_record?
        @issue.watcher_user_ids = params[:issue]['watcher_user_ids']
      end
    end
    @issue.author = User.current
    @priorities = IssuePriority.all
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current, true)
  end

  def check_for_default_issue_status
    if IssueStatus.default.nil?
      render_error l(:error_no_default_issue_status)
      return false
    end
  end

end
