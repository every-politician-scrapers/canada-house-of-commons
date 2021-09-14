#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'

official = CSV.table('data/official-raw.csv')

data = official.map do |row|
  {
    name:         row.values_at(:first_name, :last_name).join(' '),
    constituency: row[:constituency],
    party:        row[:political_affiliation],
    start_date:   row[:start_date].to_s.split(' ').first,
    end_date:     row[:end_date].to_s.split(' ').first,
  }
end

puts data.first.keys.to_csv
puts data.map(&:values).map(&:to_csv)
