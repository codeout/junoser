require 'junoser/xsd/base'
require 'junoser/xsd/element'

module Junoser
  module Xsd
    class Choice
      include Base

      def config
        @config ||= children.map {|child|
          case child.name
          when 'element'
            Junoser::Xsd::Element.new(child, depth: @depth+1)
          when 'choice'
            Junoser::Xsd::Choice.new(child, depth: @depth+1)
          else
            raise "ERROR: unknown element: #{child.name}"
          end
        }
      end

      def to_s
        case
        when config.empty?
          ''
        when has_single_child_of?(Junoser::Xsd::Choice)
          format('c(', config.first.config.map(&:to_s).join(",\n"), ')')
        else
          format('c(', config.map(&:to_s).join(",\n"), ')')
        end
      end
    end
  end
end
