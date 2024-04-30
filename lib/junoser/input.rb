module Junoser
  class Input
    def initialize(io_or_string)
      @io_or_string = io_or_string
    end

    def read
      content = if @io_or_string.respond_to?(:read)
                  @io_or_string.read
                else
                  @io_or_string.to_s
                end

      content = remove_blank_and_comment_line(content)
      content = unify_carriage_return(content)
      content = unify_square_brackets(content)
    end


    private

    # As for comment line, a trailing comment after configuration will be processed by parslet
    def remove_blank_and_comment_line(str)
      str.gsub! /^\s*#.*/, ''
      str.gsub! /^\s*\/\*((?!\*\/).)*\*\//m, ''
      str.gsub! /\n\s*/, "\n"
      str.strip
    end

    def unify_carriage_return(str)
      str.gsub! /\r\n?/, "\n"
      str
    end

    # Statements or [ ... ] may be split into multiple lines. This method unifies them into one line.
    def unify_square_brackets(str)
      lines = []

      open_brackets = 0
      str.split("\n").each do |line|
        raise "ERROR: invalid statement: #{line}" if open_brackets < 0

        if open_brackets == 0
          lines << line
        else
          lines.last << " " << line
        end

        open_brackets += line.count('[') - line.count(']')
      end

      lines.join("\n")
    end
  end
end
