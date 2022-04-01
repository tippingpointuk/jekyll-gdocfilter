# frozen_string_literal: true

require_relative "gdocfilter/version"
require 'nokogiri'
require 'open-uri'
require 'css_parser'

module Jekyll
  module Gdocfilter
    class Error < StandardError; end
    ##
    # Parses a google doc link to neatly embedable html,
    # using the +google_doc+ method.

    def replace_links(html)
      # Removes the google.com proxy from links in the doc
      html.css('a').each do |link|
        href = URI(link.attributes["href"].value)
        next unless href.query
        query = CGI.parse(href.query)
        next unless query['q'][0]
        link.attributes['href'].value = query['q'][0]
      end
      @html = html
    end
    def reduce_styles(css)
      # Extract basic styling from the <style> tag at top of document
      # ie. bold, colours
      # But not any of the layout/spacing/font-type styles
      allowed_rules = [
        'font-weight',
        # 'color',
        'font-style',
        'text-decoration'
      ]

      parser_css.add_block! css

      parser_css.each_rule_set do |rule_set|
        # puts rule_set['declarations']['declarations']
        rule_set.each_declaration do |d|
          rule_set.remove_declaration! d unless allowed_rules.include? d
        end
      end

      # parser_css.each_selector do |selector, declarations, specificity|
      #   next unless selector =~ /^[\d\w\s\#\.\-]*$/ # Check if is real selector
      #
      #
      # end

      @parser_css
    end

    def inline_styles(html)
      css = reduce_styles html.css('style').inner_html
      css.each_selector do |selector, declarations, specificity|
        next unless selector =~ /^[\d\w\s\#\.\-]*$/ # Check if is real selector
        elements = html.css(selector)
        elements.each do |e|
          e['style'] = [e["style"], declarations].compact.join(" ")
        end
      end
      @html = html
    end

    def convert_headings(html)
      # Convert  <span class=title>s to <h1 class=title> elements
      # Downsize headings by 1
      (5).downto(1) do |n|
        heading = html.at_css "h#{n}"
        if heading
          heading.name = "h#{n + 1}"
        end
      end

      title = html.at_css 'p.title'
      if title
        title.name = 'h1'
      end

      @html = html
    end

    def parser_css
      @parser_css ||= CssParser::Parser.new
    end

    def google_doc(link)
      # TODO:
      # * Properly nest lists
      ids = /[-\w]{25,}/.match(link)
      return unless ids
      f = URI.open "https://docs.google.com/feeds/download/documents/export/Export?id=#{ids[0]}&exportFormat=html"
      @html = Nokogiri::HTML.parse f
      replace_links @html
      inline_styles @html
      convert_headings @html
      @html.css('body').inner_html
    end
  end
end

Liquid::Template.register_filter(Jekyll::Gdocfilter)
