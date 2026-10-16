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
          child = config.first
          str = join(child.config)
          return '' if str.empty?

          child.sequential_arguments? ? fmt('s(', str, ')') : fmt('c(', str, ')')
        elsif sequential_arguments?
          fmt('s(', join(config), ')')
        else
          fmt('c(', join(config), ')')
        end
      end

      def unbounded?
        xml['maxOccurs'] == 'unbounded'
      end

      # xsd describes a sequence of positional arguments as an unbounded choice of
      # "nokeyword" elements, eg. "priority <setup-priority> <reservation-priority>".
      def sequential_arguments?
        # a bounded choice means one of the arguments, which is a single argument
        unbounded? && config.size > 1 &&
          # Strictly, a sequence should cover the arguments only, eg. c("foo", s(arg, arg)).
          # In .xsd, however, such a choice always has arguments only, so all? is enough.
          config.all? { |c| c.is_a?(Junoser::Xsd::Element) && c.nokeyword? }
      end

      private

      # drop a child that renders as an empty string, because an empty operand breaks the generated parser
      def join(children)
        children.map(&:to_s).reject(&:empty?).join(",\n")
      end
    end
  end
end
