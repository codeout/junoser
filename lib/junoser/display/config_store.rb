require 'forwardable'

module Junoser
  module Display
    class ConfigStore
      extend Forwardable

      OFFSET = '    '

      def initialize(depth=0)
        @hash = {}
        @depth = depth
      end

      def push(str)
        store = self

        join_arg(str).split("\n").each_with_index do |element, index|
          store[element] ||= self.class.new(index+1)
          store = store[element]
        end
      end
      alias << push

      def to_s
        str = ''

        each do |k, v|
          if v.empty?
            str << OFFSET*@depth << "#{k};\n"
          else
            str << OFFSET*@depth << "#{k} {\n"
            str << v.to_s.chop << "\n"
            str << OFFSET*@depth << "}\n"
          end
        end

        str
      end

      def_delegators :@hash, :[], :[]=, :each, :empty?

      private

      def join_arg(str)
        str.gsub!(/\narg\((.*)\)$/) { " #$1" }
        str.gsub!(/arg\((.*)\)/) { "#$1" }
        str
      end
    end
  end
end
