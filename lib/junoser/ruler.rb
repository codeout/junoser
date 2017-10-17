module Junoser
  class Ruler
    OFFSET = '    '

    def initialize(input)
      @rule = input
    end

    def to_rule
      rule_header << rule << rule_footer
    end

    def rule
      str = @rule.read
      str = process_reserved_element(str)
      str = str.split(/\n/).map {|l| format(process_line(l)) }.join("\n")
    end


    private

    def process_line(str)
      return str if str =~ /^(.* do|end)$/

      str.gsub!(/("[^"]+")/) { "str(#$1)" }  # "foo" -> str("foo")

      str.gsub!(/^(\s*)arg(\.as\(:\S+\))? \($/) { "#{$1}b(arg#$2," }  # arg ( -> b(arg,
      str.gsub!(/^(\s*)(str\(\S+\)) ([^ \t\n\r\f\(|,]+)(\.as\(:\S+\))?(,?)$/) { "#{$1}a(#$2, #$3)#$4#$5" }  # str("foo") bar -> a(str("foo"), bar)
      str.gsub!(/^(\s*)(str\(\S+\)) \((.*)\)(,?)$/) { "#{$1}a(#$2, #$3)#$4" }  # str("foo") (a | b) -> a(str("foo"), a | b)

      str.gsub!(/^(\s*)(str\(\S+\)) \($/) { "#{$1}b(#$2," }  # str("foo") ( -> b(str("foo"),
      str.gsub!(/^(\s*)(\(.*\))(\.as\(:\S\))? \($/) { "#{$1}b(#$2#$3," }  # (a | b) ( -> b((a | b),
      str.gsub!(/^(\s*)(str\(\S+\)) ([^ \t\n\r\f\(|,]+) \($/) { "#{$1}b(a(#$2, #$3)," }  # str("foo") bar ( -> b(a(str("foo"), bar),
      str.gsub!(/^(\s*)(str\(\S+\)) \((.*)\) \($/) { "#{$1}a(#$2, #$3," }  # str("foo") (a | b) ( -> a(str("foo"), a | b,

      str
    end

    def process_reserved_element(str)
      str.gsub! /"\$\S+"/, 'arg'

      str
    end

    def format(str, offset=OFFSET)
      case str
      when String
        str.empty? ? '' : offset + str
      when Array
        str.map {|s| s.empty? ? '' : offset + s.to_s }.join("\n")
      end
    end

    def rule_header
      <<-EOS
require 'parslet'

module Junoser
  class Parser < Parslet::Parser
    def parse_lines(config)
      lines = config.split("\\n").map(&:strip)
      lines_without_deactivate = lines.reject {|l| l =~ /^deactivate/ }

      lines.inject(true) do |passed, line|
        if line =~ /^deactivate/
          if lines_without_deactivate.grep(/^\#{line.sub(/^deactivate/, 'set')}/).empty?
            next false
          else
            next passed
          end
        end

        begin
          parse line
          passed
        rescue Parslet::ParseFailed
          $stderr.puts "Invalid syntax:  \#{line}"
          false
        end
      end
    end

    # block with children maybe
    def b(object, *children)
      children.inject(object) {|rule, child| rule.as(:label) >> (space >> child.as(:child) | eos) }
    end

    # with an argument, and children maybe
    def a(object, arg, *children)
      b(object.as(:statement) >> space >> arg.as(:argument), *children)
    end

    # choice
    def c(*objects)
      objects.inject {|rule, object| rule | object }
    end

    def ca(*objects)
      objects.inject {|rule, object| rule | object } | arg
    end

    # sequence
    def s(*objects)
      # TODO:  eval "minOccurs" attribute of choice element
      objects.inject {|rule, object| rule >> (space >> object).maybe }
    end

    # sequential choice
    def sc(*objects)
      (c(*objects) >> space.maybe).repeat(0)
    end

    def sca(*objects)
      (c(*objects, arg) >> space.maybe).repeat(0)
    end

    rule(:arg)     { match('\\S').repeat(1) }
    rule(:space)   { match('\\s').repeat(1) }
    rule(:any)     { match('.').repeat(1) }
    rule(:eos)     { match('$') }
    rule(:dotted)  { match('[^. \\t\\n\\r\\f]').repeat(1) >> str('.') >> match('[^. \\t\\n\\r\\f]').repeat(1) }
    rule(:quote)   { str('"') >> match('[^"]').repeat(1) >> str('"') }
    rule(:address) { match('[0-9a-fA-F:\.]').repeat(1) }
    rule(:prefix ) { address >> (str('/') >> match('[0-9]').repeat(1)).maybe }

    root(:set)
    rule(:set) { str('set') >> space >> configuration.as(:config) >> comment.maybe }

    rule(:comment) { space.maybe >> (hash_comment | slash_asterisk) }
    rule(:hash_comment) { str('#') >> any.maybe }
    rule(:slash_asterisk) { str('/*') >> match('(?!\\*\\/).').repeat(0) >> str('*/') }

      EOS
    end

    def rule_footer
      <<-EOS

  end
end
      EOS
    end
  end
end
