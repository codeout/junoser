module Junoser
  module Display
    module Base
      attr_accessor :output

      def initialize(io_or_string)
        @input = io_or_string
        @output = $stdout
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
    end
  end
end
