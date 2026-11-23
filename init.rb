# Redmine Issue Query Set
# Copyright (C) 2026 Niltek Arge
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version. See the LICENSE file for details.

require_relative 'lib/redmine_issue_query_set'
require_relative 'lib/redmine_issue_query_set/appender'
require_relative 'lib/redmine_issue_query_set/hooks'

Redmine::Plugin.register :redmine_issue_query_set do
  name 'Issue Query Set'
  author 'Niltek Arge'
  author_url 'https://github.com/oten52'
  description 'Seçilen iş numaralarını kayıtlı bir sorgunun iş listesine virgülle ekler.'
  version '0.1.0'
  url 'https://github.com/oten52/Redmine.IssueQuerySet'
  requires_redmine version_or_higher: '4.2'

  directory File.expand_path(__dir__)
end
