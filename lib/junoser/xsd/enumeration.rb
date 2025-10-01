# frozen_string_literal: true

require 'junoser/xsd/base'

module Junoser
  module Xsd
    class Enumeration
      include Base

      def initialize(xml, options = {})
        super
      end

      def config
        raise 'ERROR: unknown Enumeration format' if children.size > 1

        has_match? ? ['arg'] : [%("#{xml['value']}")]
      end

      def to_s
        if nokeyword?
          fmt("#{OFFSET}arg")
        else
          fmt(OFFSET + config.first)
        end
      end

      private

      def has_match? # rubocop:disable Naming/PredicatePrefix
        true unless xml.xpath('.//match').empty?
      end
    end
  end
end
