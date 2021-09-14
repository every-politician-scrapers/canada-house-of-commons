#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require_relative './../../lib/unspan_all_tables'

require 'open-uri/cached'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class MembersPage < Scraped::HTML
  decorator RemoveReferences
  decorator WikidataIdsDecorator::Links
  decorator UnspanAllTables

  field :members do
    member_rows.map { |tr| fragment(tr => Member) }.reject(&:vacant?).map(&:to_h)
  end

  private

  def member_rows
    table.flat_map { |table| table.xpath('.//tr[td]') }
  end

  def table
    noko.xpath('//h2[contains(.,"Members")]/following::table[.//th[contains(.,"Electoral district")]]')
  end
end

class Member < Scraped::HTML
  GROUPS = {
  }

  def vacant?
    tds[1].text.tidy == 'Vacant'
  end

  field :item do
    name_link.attr('wikidata') rescue binding.pry
  end

  field :name do
    name_link.text.tidy
  end

  field :group do
    GROUPS[groupname] ||= tds[2].css('a/@wikidata').text
  end

  field :groupname do
    tds[2].text.tidy
  end

  field :district do
    district_link.attr('wikidata')
  end

  field :districtname do
    district_link.text.tidy
  end

  private

  def tds
    noko.css('td')
  end

  def name_link
    tds[1].css('a').first
  end

  def district_link
    tds[3].css('a').first
  end
end

url = 'https://en.wikipedia.org/wiki/List_of_House_members_of_the_43rd_Parliament_of_Canada'
data = MembersPage.new(response: Scraped::Request.new(url: url).response).members

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
