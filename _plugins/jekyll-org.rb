# -*- coding: utf-8 -*-
require 'org-ruby'

module Jekyll
  class OrgConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /org/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      output = Orgmode::Parser.new(content).to_html

      # Clean up in output from ZERO WIDTH SPACE char which can
      # present in input Org file
      output.gsub "​", ""
    end
  end

  module Orgify
    # Convert an Org string into HTML output.
    #
    # input - The Org String to convert.
    #
    # Returns the HTML formatted String.
    def orgify(input)
      site = @context.registers[:site]
      converter = site.getConverterImpl(Jekyll::OrgConverter)
      output = converter.convert(input)

      # Clean up in output from ZERO WIDTH SPACE char which can
      # present in input Org file
      output.gsub "​", ""
    end
  end
end

Liquid::Template.register_filter(Jekyll::Orgify)
