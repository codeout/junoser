require 'junoser/xsd/base'
require 'junoser/xsd/restriction'
require 'junoser/xsd/union'

module Junoser
  module Xsd
    class SimpleType
      include Base

      def config
        @config ||= children.map {|child|
          case child.name
          when 'restriction'
            Junoser::Xsd::Restriction.new(child, depth: @depth+1, parent: self)
          when 'union'
            Junoser::Xsd::Union.new(child, depth: @depth+1, parent: self)
          else
            raise "ERROR: unknown element: #{child.name}"
          end
        }
      end

      def to_s
        format(config.first.to_s.strip)
      end
    end
  end
end
