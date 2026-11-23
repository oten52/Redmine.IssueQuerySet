get 'issue_query_set', :to => 'redmine_issue_query_set#index'
post 'issue_query_set', :to => 'redmine_issue_query_set#apply'
get 'projects/:project_id/issue_query_set', :to => 'redmine_issue_query_set#index'
post 'projects/:project_id/issue_query_set', :to => 'redmine_issue_query_set#apply'
