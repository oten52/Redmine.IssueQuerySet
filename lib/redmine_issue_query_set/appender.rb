# frozen_string_literal: true

module RedmineIssueQuerySet
  class Appender
    def self.preview(query, issue_ids)
      new(query, issue_ids).preview
    end

    def self.call(query, issue_ids)
      new(query, issue_ids).call
    end

    def initialize(query, issue_ids)
      @query = query
      @issue_ids = RedmineIssueQuerySet.integer_list(issue_ids)
    end

    def preview
      existing = existing_ids
      {
        :operator => operator,
        :existing => existing,
        :added => (@issue_ids - existing),
        :merged => (existing + @issue_ids).uniq
      }
    end

    def call
      info = preview
      return [:operator, info] if info[:operator].present? && info[:operator] != '='
      return [:empty, info] if info[:added].empty?
      return [:too_many, info] if info[:merged].size > 5000

      filters = copied_filters
      filters.delete(:issue_id)
      filters['issue_id'] = {:operator => '=', :values => [info[:merged].join(',')]}
      @query.filters_will_change! if @query.respond_to?(:filters_will_change!)
      @query.filters = filters
      if @query.save
        [:ok, info]
      else
        [:invalid, info]
      end
    end

    private

    def existing_ids
      RedmineIssueQuerySet.integer_list(filter_values, 5000)
    end

    def operator
      current = current_filter
      return '' unless current

      (current[:operator] || current['operator']).to_s
    end

    def filter_values
      current = current_filter
      return [] unless current

      current[:values] || current['values'] || []
    end

    def current_filter
      filters = @query.filters
      return nil unless filters.is_a?(Hash)

      filters['issue_id'] || filters[:issue_id]
    end

    def copied_filters
      source = @query.filters
      return {} unless source.is_a?(Hash)

      copy = {}
      source.each {|key, value| copy[key] = value}
      copy
    end
  end
end
