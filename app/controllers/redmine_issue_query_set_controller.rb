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

  def queries
    list = editable_queries('all')
    projects = Project.where(:id => list.map(&:project_id).compact.uniq).index_by(&:id)
    rows = list.map do |query|
      project = projects[query.project_id]
      {
        :id => query.id,
        :name => query.name.to_s,
        :project_id => query.project_id,
        :project => project ? project.name.to_s : l(:redmine_issue_query_set_global)
      }
    end
    render :json => {:queries => rows}
  end

  def apply
    @issues = selected_issues
    @issue_ids = @issues.map(&:id)
    @scope = selected_scope
    @back_url = safe_back
    if @issues.empty?
      return fail_apply(l(:redmine_issue_query_set_none))
    end

    ids = RedmineIssueQuerySet.integer_list(params[:query_ids], 50)
    ids = RedmineIssueQuerySet.integer_list(params[:query_id], 50) if ids.empty?
    if ids.empty?
      return fail_apply(l(:redmine_issue_query_set_no_queries))
    end

    results = ids.map {|id| apply_one(id)}
    if request.xhr?
      render :json => {:ok => results.any? {|row| row[:ok]}, :results => results}
      return
    end

    row = results.first || {}
    if row[:ok]
      flash[:notice] = row[:message]
      redirect_to(@back_url)
    else
      flash[:error] = row[:message] || l(:redmine_issue_query_set_failed)
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

  def apply_one(query_id)
    query = visible_query(query_id)
    unless query && query.editable_by?(User.current)
      return {:id => query_id, :ok => false, :message => l(:redmine_issue_query_set_denied)}
    end

    status, info = RedmineIssueQuerySet::Appender.call(query, @issue_ids)
    message = case status
              when :ok
                l(:redmine_issue_query_set_done, :name => query.name, :number => info[:added].size)
              when :empty
                l(:redmine_issue_query_set_already, :name => query.name)
              when :operator
                l(:redmine_issue_query_set_operator, :name => query.name)
              else
                text = query.errors.full_messages.join(', ')
                text.present? ? text : l(:redmine_issue_query_set_failed)
              end
    {:id => query.id, :name => query.name.to_s, :ok => status == :ok || status == :empty, :message => message}
  end

  def fail_apply(message)
    if request.xhr?
      render :json => {:ok => false, :error => message, :results => []}, :status => 422
    else
      flash[:error] = message
      redirect_to(safe_back)
    end
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
