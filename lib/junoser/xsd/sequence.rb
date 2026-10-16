# frozen_string_literal: true

require 'junoser/xsd/base'
require 'junoser/xsd/choice'
require 'junoser/xsd/element'

module Junoser
  module Xsd
    class Sequence
      include Base

      def config
        @config ||= children.map do |child|
          case child.name
          when 'choice'
            Junoser::Xsd::Choice.new(child, depth: @depth + 1, parent: self)
          when 'element'
            Junoser::Xsd::Element.new(child, depth: @depth + 1, parent: self)
          when 'any'
            'any'
          else
            raise "ERROR: unknown element: #{child.name}"
          end
        end
      end

      def to_s
        case
        when config.empty?
          ''
        when has_single_child_of?(Junoser::Xsd::Choice)
          child = config.first
          str = child.config.map(&:to_s).reject(&:empty?).join(",\n")

          return if str.empty?

          # Assuming that <xsd:sequence> always has <xsd:complexType> as the parent
          if child.sequential_arguments?
            fmt('s(', str, ')')
          elsif parent.parent&.oneliner? && child.unbounded?
            fmt('sc(', str, ')')
          else
            fmt('c(', str, ')')
          end
        else
          str = config.map { |c| c.is_a?(String) ? fmt(OFFSET + c) : c.to_s }.reject(&:empty?).join(",\n")
          fmt('s(', str, ')')
        end
      end
    end
  end
end
