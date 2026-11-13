# frozen_string_literal: true

require "nokogiri"

module FirstHtmlParagraph
  def first_html_paragraph(html)
    paragraph = Nokogiri::HTML5.fragment(html.to_s).at_css("p")
    paragraph ? paragraph.to_html : ""
  end
end

Liquid::Template.register_filter(FirstHtmlParagraph)
