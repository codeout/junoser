# frozen_string_literal: true

require 'junoser/xsd/base'
require 'junoser/xsd/element'

module Junoser
  module Xsd
    class Choice
      include Base

      def config
        @config ||= children.map do |child|
          case child.name
          when 'element'
            Junoser::Xsd::Element.new(child, depth: @depth + 1, parent: self)
          when 'choice'
            Junoser::Xsd::Choice.new(child, depth: @depth + 1, parent: self)
          else
            raise "ERROR: unknown element: #{child.name}"
          end
        end
      end

      def to_s
        if config.empty?
          ''
        elsif has_single_child_of?(Junoser::Xsd::Choice)
          fmt('c(', config.first.config.map(&:to_s).join(",\n"), ')')
        else
          fmt('c(', config.map(&:to_s).join(",\n"), ')')
        end
      end

      def unbounded?
        xml['maxOccurs'] == 'unbounded'
      end
    end
  end
end
