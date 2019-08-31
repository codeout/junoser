require 'forwardable'

module Junoser
  module Display
    class ConfigStore
      extend Forwardable

      OFFSET = '    '

      attr_accessor :deactivated

      def initialize(depth=0)
        @hash = {}
        @depth = depth
        @deactivated = false
      end

      def push(str)
        store = self

        join_arg(str).split("\n").each_with_index do |element, index|
          store[element] ||= self.class.new(index+1)
          store = store[element]
        end
      end
      alias << push

      def deactivate(deactivated_line)
        statement, store = matched(deactivated_line)

        if statement
          if statement == deactivated_line
            store.deactivated = true
          else
            store.deactivate(deactivated_line.sub(/^#{statement} */, ''))
          end
        else
          statement, store = inverse_matched(deactivated_line)
          if statement
            store.deactivated = true
          end
        end
      end

      def each_with_inactive(str='', &block)
        each do |k, v|
          k = "inactive: #{k}" if v.deactivated
          yield k, v, str
        end

        str
      end

      def to_s
        each_with_inactive('', &method(:hash_item_to_s))
      end

      def_delegators :@hash, :[], :[]=, :each, :empty?

      private

      def hash_item_to_s(key, value, str)
        if value.empty?
          str << OFFSET*@depth << "#{key};\n"
        else
          str << OFFSET*@depth << "#{key} {\n"
          str << value.to_s.chop << "\n"
          str << OFFSET*@depth << "}\n"
        end
      end

      def join_arg(str)
        str.gsub!(/\narg\((.*)\)$/) { " #$1" }
        str.gsub!(/arg\((.*)\)/) { "#$1" }
        str
      end

      def matched(str)
        each do |statement, store|
          # NOTE: return the first object
          return [statement, store] if str =~ /^#{statement}\b/
        end

        []
      end

      def inverse_matched(str)
        each do |statement, store|
          # NOTE: return the first object
          return [statement, store] if statement =~ /^#{str}\b/
        end

        []
      end
    end
  end
end
