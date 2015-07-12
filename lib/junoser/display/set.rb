module Junoser
  module Display
    class Set
      attr_accessor :output

      def initialize(io_or_string)
        @input = io_or_string
        @output = $stdout
      end

      def transform
        process do |current_stack, str|
          @output.puts transform_line(current_stack, str)
        end
      end

      def commit_check(&block)
        parser = Junoser::Parser.new
        failed = false

        process do |current_stack, str|
          config = transform_line(current_stack, str)

          begin
            parser.parse config
          rescue Parslet::ParseFailed
            $stderr.puts "Invalid syntax:\n#{struct(current_stack.dup, str)}"
raise
            failed = true
          end
        end

        abort if failed
      end


      private

      def read_io_or_string
        return @read_io_or_string if @read_io_or_string

        config = if @input.respond_to?(:read)
                   @input.read
                 else
                   @input.to_s
                 end

        @read_io_or_string = remove_blank_and_comment(config)
        @read_io_or_string = unify_carriage_return(@read_io_or_string)
      end

      def remove_blank_and_comment(str)
        str.gsub! /#.*/, ''
        str.gsub! /\/\*((?!\*\/).)*\*\//m, ''
        str.gsub! /\n\s*/, "\n"
        str.strip
      end

      def unify_carriage_return(str)
        str.gsub! /\r\n?/, "\n"
        str
      end

      def process(&block)
        stack = []

        read_io_or_string.split("\n").each do |line|
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
            raise "ERROR* unknown statement:  #{line}"
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
