require 'active_support/inflector'
require 'junoser/xsd/complex_type'
require 'junoser/xsd/element'
require 'nokogiri'

module Junoser
  module Xsd
    module Parsable
      def to_config
        rule = "rule(:#{self['name'].underscore}) do\n"

        case name
        when 'complexType'
          rule << Junoser::Xsd::ComplexType.new(self, depth: 1).to_s
        when 'element'
          rule << Junoser::Xsd::Element.new(self, depth: 1).content
        else
          raise "ERROR: unknown element: #{name}"
        end

        rule << "\nend\n\n"
      end

      def remove_unused
        xpath('/xsd:schema/*[self::xsd:import]').remove
        xpath('//xsd:element[@ref="undocumented" or @ref="junos:comment"]').remove
        self
      end
    end
  end
end

Nokogiri::XML::Element.include Junoser::Xsd::Parsable
