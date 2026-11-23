# frozen_string_literal: true

module RedmineIssueQuerySet
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_context_menu_end, :partial => 'redmine_issue_query_set/menu'
    render_on :view_layouts_base_body_bottom, :partial => 'redmine_issue_query_set/dialog'
  end
end
