# frozen_string_literal: true

class RedmineIssueQuerySetController < ApplicationController
  before_action :load_project
  before_action :require_issue_access

  def index
    @issues = selected_issues
    if @issues.empty?
      flash[:error] = l(:redmine_issue_query_set_none)
      redirect_to(safe_back)
      return
    end

    @issue_ids = @issues.map(&:id)
    @scope = selected_scope
    @queries = editable_queries(@scope)
    @back_url = safe_back
  end

  def apply
    @issues = selected_issues
    @issue_ids = @issues.map(&:id)
    @scope = selected_scope
    @back_url = safe_back
    query = visible_query(params[:query_id])
    unless query && query.editable_by?(User.current)
      flash[:error] = l(:redmine_issue_query_set_denied)
      redirect_to(index_location)
      return
    end
    if @issues.empty?
      flash[:error] = l(:redmine_issue_query_set_none)
      redirect_to(@back_url)
      return
    end

    status, info = RedmineIssueQuerySet::Appender.call(query, @issue_ids)
    case status
    when :ok
      flash[:notice] = l(:redmine_issue_query_set_done, :name => query.name, :number => info[:added].size)
      redirect_to(@back_url)
    when :operator
      flash[:error] = l(:redmine_issue_query_set_operator, :name => query.name)
      redirect_to(index_location)
    when :empty
      flash[:notice] = l(:redmine_issue_query_set_already, :name => query.name)
      redirect_to(index_location)
    else
      message = query.errors.full_messages.join(', ')
      flash[:error] = message.present? ? message : l(:redmine_issue_query_set_failed)
      redirect_to(index_location)
    end
  end

  private

  def load_project
    return if params[:project_id].blank?

    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
    false
  end

  def require_issue_access
    allowed = if @project
                User.current.allowed_to?(:view_issues, @project)
              else
                User.current.allowed_to?(:view_issues, nil, :global => true)
              end
    unless allowed
      deny_access
      return false
    end
    true
  end

  def selected_scope
    params[:scope].to_s == 'project' && @project ? 'project' : 'all'
  end

  def selected_issues
    ids = RedmineIssueQuerySet.integer_list(params[:ids])
    return [] if ids.empty?

    found = Issue.visible.where(:id => ids).index_by(&:id)
    ids.map {|id| found[id]}.compact
  end

  def editable_queries(scope_name)
    table = IssueQuery.table_name
    relation = IssueQuery.visible
    if scope_name == 'project' && @project
      relation = relation.where("#{table}.project_id = ?", @project.id)
    end
    relation.to_a.select {|query| query.editable_by?(User.current)}.sort_by do |query|
      [query.project_id ? 1 : 0, query.project ? query.project.name.to_s : '', query.name.to_s]
    end
  rescue ActiveRecord::ActiveRecordError
    []
  end

  def visible_query(id)
    IssueQuery.visible.find_by(:id => id.to_i)
  rescue ActiveRecord::ActiveRecordError
    nil
  end

  def safe_back
    back = params[:back_url].to_s
    if back.start_with?('/') && !back.start_with?('//') && !back.include?('\\')
      back
    elsif @project
      project_issues_path(@project)
    else
      issues_path
    end
  end

  def index_location
    url_for({
      :controller => 'redmine_issue_query_set',
      :action => 'index',
      :project_id => @project,
      :scope => @scope,
      :ids => @issue_ids,
      :back_url => @back_url,
      :only_path => true
    })
  end
end
