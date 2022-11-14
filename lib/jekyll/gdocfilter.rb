# frozen_string_literal: true

require_relative "gdocfilter/version"
require "nokogiri"
require "open-uri"
require "css_parser"
require "liquid"

module Jekyll
  ##
  # Parses a google doc link to neatly embedable html,
  # using the +google_doc+ method.
  module Gdocfilter
    class Error < StandardError; end

    def get_query_from_link(link)
      return unless link

      href = URI(link)
      return link unless href.query

      query = CGI.parse(href.query)
      return href unless query["q"][0]

      query["q"][0]
    end

    def replace_links(html)
      # Removes the google.com proxy from links in the doc
      html.css("a").each do |link|
        next unless link.attributes["href"]

        href = link.attributes["href"].value
        link.attributes["href"].value = get_query_from_link(href)
      end
      @html = html
    end

    def reduce_styles(css)
      # Extract basic styling from the <style> tag at top of document
      # ie. bold, colours
      # But not any of the layout/spacing/font-type styles
      allowed_rules = %w[font-weight font-style text-decoration]
      parser_css.add_block! css
      parser_css.each_rule_set do |rule_set|
        rule_set.each_declaration do |d|
          rule_set.remove_declaration! d unless allowed_rules.include? d
        end
      end
      @parser_css
    end

    def inline_styles(html)
      css = reduce_styles html.css("style").inner_html
      css.each_selector do |selector, declarations, _specificity|
        next unless selector =~ /^[\d\w\s\#.\-]*$/ # Check if is real selector

        elements = html.css(selector)
        elements.each do |e|
          e["style"] = [e["style"], declarations].compact.join(" ")
        end
      end
      @html = html
    end

    def convert_headings(html)
      # Convert  <span class=title>s to <h1 class=title> elements
      # Downsize headings by 1
      (5).downto(1) do |n|
        heading = html.at_css "h#{n}"
        heading.name = "h#{n + 1}" if heading
      end

      title = html.at_css "p.title"
      title.name = "h1" if title

      @html = html
    end

    def parser_css
      @parser_css ||= CssParser::Parser.new
    end

    def get_html(link)
      ids = /[-\w]{25,}/.match(link)
      return unless ids

      @url = URI(link)
      return unless @url.host == "docs.google.com"

      link = "https://docs.google.com/feeds/download/documents/export/Export?id=#{ids[0]}&exportFormat=html"

      f = get_file(link)
      return unless f

      @html = Nokogiri::HTML.parse f
    end

    def get_file(url)
      begin
        f = URI.open url
      rescue OpenURI::HTTPError
        return
      end
      return unless f.status[1] == "OK"

      f
    end

    def google_doc(link)
      return unless get_html(link)

      replace_links @html
      inline_styles @html
      convert_headings @html
      # TODO: Properly nest lists
      @html.css("body").inner_html
    end
  end
end

Liquid::Template.register_filter(Jekyll::Gdocfilter)
