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

      content = remove_blank_and_comment(content)
      content = unify_carriage_return(content)
    end


    private

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
