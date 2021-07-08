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
    end

    def read2
      content1 = if @io_or_string.respond_to?(:read)
                   @io_or_string.file.read
                 else
                   @io_or_string.to_s
                 end
      content1 = remove_blank_and_comment_line(content1)
      content1 = unify_carriage_return(content1)
      @io_or_string.skip
      content2 = if @io_or_string.respond_to?(:read)
                   @io_or_string.file.read
                 else
                   @io_or_string.to_s
                 end
      content2 = remove_blank_and_comment_line(content2)
      content2 = unify_carriage_return(content2)
      return content1,content2
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
  end
end
