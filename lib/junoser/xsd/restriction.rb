require 'junoser/xsd/base'
require 'junoser/xsd/enumeration'
require 'junoser/xsd/simple_type'

module Junoser
  module Xsd
    class Restriction
      include Base

      def children
        @children||= xml.xpath('./*[not(self::xsd:annotation or ' +
                               'self::xsd:minInclusive or self::xsd:maxInclusive or ' +
                               'self::xsd:minLength or self::xsd:maxLength)]')
      end

      def config
        @config ||= children.map {|child|
          case child.name
          when 'enumeration'
            Junoser::Xsd::Enumeration.new(child, depth: @depth+1)
          when 'simpleType'
            Junoser::Xsd::SimpleType.new(child, depth: @depth+1)
          when 'attribute'
          else
            raise "ERROR: unknown element: #{child.name}"
          end
        }.compact
      end

      def to_s
        return format('arg') if config.empty?

        str = '(' + config.map {|c| c.to_s.strip }.join(' | ') + ')'
        format(str)
      end
    end
  end
end
