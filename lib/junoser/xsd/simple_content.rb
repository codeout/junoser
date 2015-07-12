require 'junoser/xsd/base'
require 'junoser/xsd/restriction'

module Junoser
  module Xsd
    class SimpleContent
      include Base

      def config
        @config ||= children.map {|child|
          case child.name
          when 'restriction'
            Junoser::Xsd::Restriction.new(child, depth: @depth+1)
          when 'extension'
            'arg'
          else
            raise "ERROR: unknown element: #{child.name}"
          end
        }.compact
      end

      def to_s
        return if config.empty?
        raise "ERROR: simpleContent shouldn't have multiple children" if config.size > 1

        child = config.first
        child.is_a?(String) ? format(OFFSET + child) : child.to_s
      end
    end
  end
end
