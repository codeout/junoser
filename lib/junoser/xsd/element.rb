require 'active_support/inflector'
require 'junoser/xsd/base'
require 'junoser/xsd/complex_type'

module Junoser
  module Xsd
    class Element
      include Base

      def initialize(xml, options={})
        super
        @argument = find_name_element || find_single_simple_type || find_simple_type_attribute
      end

      def config
        @config ||= children.map {|child|
          case child.name
          when 'complexType'
            Junoser::Xsd::ComplexType.new(child, depth: @depth+1)
          when 'simpleType'
            'arg'
          else
            raise "ERROR: unknown element: #{child.name}"
          end
        }
      end

      def to_s
        str = if content.empty?
                format(label)
              else
                if label
                  format("#{label} (", content, ')')
                else
                  format('(', content, ')')
                end
              end

        oneliner? ? "#{str}.as(:oneline)" : str
      end

      def content
        @content ||= if config.empty?
                     xml['type'] ? format(OFFSET + xml['type'].underscore) : ''
                   else
                     config.map {|c| c.is_a?(String) ? format(OFFSET + c) : c.to_s }.join("\n")
                   end
      end


      private

      def label
        return unless xml['name']

        %["#{xml['name']}" #{argument}].strip
      end

      def argument
        return unless @argument

        case
        when @argument.is_a?(String)
          @argument
        when @argument.name == 'simpleType'
          'arg'
        else
          arg = Junoser::Xsd::Element.new(@argument, depth: @depth+1).config
          raise "ERROR: argument shouldn't consist of multiple elements" if arg.size > 1
          arg.first.to_s.strip
        end
      end

      def find_name_element
        xml.xpath('./xsd:complexType/xsd:sequence/xsd:element[@name="name"]').remove.first
      end

      def find_single_simple_type
        simples = xml.xpath('./xsd:simpleType').remove
        raise "ERROR: Element shouldn't have simpleType child and another" if simples.size > 1
        simples.first
      end

      def find_simple_type_attribute
        if xml['type'] =~ /^xsd:.*/
          xml.remove_attribute 'type'
          'arg'
        end
      end
    end
  end
end
