require 'junoser/xsd/base'
require 'junoser/xsd/element'
require 'junoser/xsd/sequence'
require 'junoser/xsd/simple_content'

module Junoser
  module Xsd
    class ComplexType
      include Base

      def initialize(xml, options={})
        super
        raise "ERROR: #{xml.name} shouldn't have name '#{xml['name']}'" if xml['name'] && !root?
        @argument = find_name_element
      end

      def config
        @config ||= children.map {|child|
          case child.name
          when 'sequence'
            Junoser::Xsd::Sequence.new(child, depth: @depth+1)
          when 'simpleContent'
            Junoser::Xsd::SimpleContent.new(child, depth: @depth+1)
          when 'attribute'
            'arg'
          else
            raise "ERROR: unknown element: #{child.name}"
          end
        }.compact
      end

      def to_s
        str = config.map {|c| c.is_a?(String) ? format(OFFSET + c) : c.to_s }.compact.join("\n")

        case [!argument.nil?, !str.empty?]
        when [true, true]
          format("#{argument} (", str, ')')
        when [true, false]
          format(argument)
        when [false, true]
          str
        else
          ''
        end
      end


      private

      def argument
        return unless @argument

        arg = Junoser::Xsd::Element.new(@argument).config
        raise "ERROR: argument shouldn't consist of multiple elements" if arg.size > 1
        arg.first.to_s.strip
      end

      def find_name_element
        xml.xpath('./xsd:sequence/xsd:element[@name="name"]').remove.first
      end
    end
  end
end
