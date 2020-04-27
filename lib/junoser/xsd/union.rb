require 'junoser/xsd/base'

module Junoser
  module Xsd
    class Union
      include Base

      def config
        @config ||= children.map {|child|
          case child.name
          when 'simpleType'
            Junoser::Xsd::SimpleType.new(child, depth: @depth+1, parent: self)
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
