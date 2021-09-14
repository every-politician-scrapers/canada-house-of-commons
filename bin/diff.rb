#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'

REMAP = {
  party:        {
    'Conservative Party of Canada' => 'Conservative',
    'Green Party of Canada'        => 'Green Party',
    'Liberal Party of Canada'      => 'Liberal',
    'New Democratic Party'         => 'NDP',
    'independent politician'       => 'Independent',
  },
  constituency: {
    'Rosemont–La Petite-Patrie' => 'Rosemont—La Petite-Patrie',
  },
}.freeze

CSV::Converters[:remap] = ->(val, field) { (REMAP[field.header] || {}).fetch(val, val) }

# Standardise data
class Comparison < EveryPoliticianScraper::Comparison
  def wikidata_csv_options
    { converters: [:remap] }
  end
end

diff = Comparison.new('wikidata/results/current-members.csv', 'data/official.csv').diff
puts diff.sort_by { |r| [r.first, r[1].to_s] }.reverse.map(&:to_csv)
