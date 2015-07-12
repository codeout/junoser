module Junoser
  module Xsd
    module Base
      attr_reader :xml

      OFFSET = '  '

      def initialize(xml, options={})
        @xml = xml
        @depth = options[:depth] || 0
      end

      def config
        raise "ERROR: no implementation"
      end

      def children
        @children||= xml.xpath('./*[not(self::xsd:annotation)]')
      end

      def root?
        @depth == 1
      end

      def inspect
        ["#<#{self.class}:0x#{object_id}",
         "xml=#{xml.namespace.prefix}:#{xml.name}" <<
         " attributes=" << Hash[xml.attributes.map {|k, v| [k, v.value] }].to_s <<
         (respond_to?(:label) ? " label=#{label}" : ''),
         "config=[",
         *config.map {|c| c.inspect },
         ']>'].join("\n#{OFFSET*(@depth+1)}")
      end


      private

      def has_single_child_of?(klass)
        config.size == 1 && config.first.is_a?(klass)
      end

      def format(header, content=nil, footer=nil)
        str = OFFSET*@depth << header.to_s
        str << "\n" << content if content
        str << "\n" << OFFSET*@depth << footer if footer
        str
      end
    end
  end
end
