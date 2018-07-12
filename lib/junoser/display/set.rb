require 'parslet'
require 'junoser/input'

module Junoser
  module Display
    class Set
      def initialize(io_or_string)
        @input = io_or_string
      end

      def transform
        result = ''

        process do |current_stack, str|
          result << transform_line(current_stack, str) << "\n"
        end

        result
      end

      def commit_check(&block)
        begin
          lines = transform
        rescue
          $stderr.puts $!
          return false
        end

        parser = Junoser::Parser.new
        parser.parse_lines(lines)
      end


      private

      def process(&block)
        stack = []

        Junoser::Input.new(@input).read.split("\n").each do |line|
          case line
          when /(?!.*})(.*){/
            stack.push $1.strip
          when /}\s*$/
            stack.pop
          when /((?!\[).*)\[(.*)\];/
            $2.split("\s").each do |i|
              yield stack, "#{$1.strip} #{i}"
            end
          when /(.*);/
            yield stack, $1
          else
            raise "ERROR: unknown statement:  #{line}"
          end
        end
      end

      def transform_line(current_stack, str)
        statements = []
        current_statement = ''

        current_stack.each do |stack|
          if stack.gsub!('inactive: ', '')
            statements << "deactivate #{current_statement}#{stack}"
          end
          current_statement << "#{stack} "
        end

        if str.gsub!('inactive: ', '')
          statements << "deactivate #{current_statement}#{str}"
        end

        statements.unshift "set #{current_statement}#{str}"
        statements.join("\n")
      end
    end
  end
end
