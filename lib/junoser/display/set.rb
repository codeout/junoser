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
        parser = Junoser::Parser.new
        passed = true

        process do |current_stack, str|
          config = transform_line(current_stack, str)

          begin
            parser.parse config
          rescue Parslet::ParseFailed
            $stderr.puts "Invalid syntax:  #{config}"
            passed = false
          end
        end

      rescue
        $stderr.puts $!
        passed = false
      ensure
        return passed
      end


      private

      def process(&block)
        stack = []

        Junoser::Input.new(@input).read.split("\n").each do |line|
          case line
          when /(.*){/
            stack.push $1.strip
          when '}'
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
        statement = if current_stack.empty?
                      str
                    else
                      statement = "#{current_stack.join(' ')} #{str}"
                    end

        if statement.gsub!('inactive: ', '')
          "deactivate #{statement}"
        else
          "set #{statement}"
        end
      end

      def struct(stack, statement, offset=2)
        width = 2
        if label = stack.shift
          %[#{" "*offset}#{label} {
#{struct(stack, statement, width+offset)}
#{" "*offset}}]
        else
          %[#{" "*offset}#{statement};]
        end
      end
    end
  end
end
