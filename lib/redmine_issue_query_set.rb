# frozen_string_literal: true

module RedmineIssueQuerySet
  LIMIT = 500

  def self.integer_list(value, limit = LIMIT)
    values = value.is_a?(Array) ? value : [value]
    values.flat_map {|item| item.to_s.scan(/\d+/)}.map(&:to_i).select {|id| id > 0}.uniq.first(limit)
  end
end
