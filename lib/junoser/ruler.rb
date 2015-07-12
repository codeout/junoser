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

      str.gsub!(/^(\s*)arg \($/) { "#{$1}b(arg," }   # arg ( -> b(arg,
      str.gsub!(/^(\s*)(str\(\S+\)) ([^ \t\n\r\f\(|,]+)(,?)$/) { "#{$1}a(#$2, #$3)#$4" }  # str("foo") bar -> a(str("foo"), bar)
      str.gsub!(/^(\s*)(str\(\S+\)) \((.*)\)(,?)$/) { "#{$1}a(#$2, #$3)#$4" }  # str("foo") (a | b) -> a(str("foo"), a | b)

      str.gsub!(/^(\s*)(str\(\S+\)) \($/) { "#{$1}b(#$2," }  # str("foo") ( -> b(str("foo"),
      str.gsub!(/^(\s*)\((.*)\) \($/) { "#{$1}b(#$2," }    # (a | b) ( -> b((a | b),
      str.gsub!(/^(\s*)(str\(\S+\)) ([^ \t\n\r\f\(|,]+) \($/) { "#{$1}b(a(#$2, #$3)," }  # str("foo") bar ( -> b(a(str("foo"), bar),
      str.gsub!(/^(\s*)(str\(\S+\)) \((.*)\) \($/) { "#{$1}a(#$2, #$3," }  # str("foo") (a | b) ( -> a(str("foo"), a | b,

      str
    end

    def process_reserved_element(str)
      str.gsub! /"\$\S+"/, 'arg'
      str.gsub! /"contents" \(\s*syslog_object\s*\)/, 'syslog_object'
      str.gsub!(/^(\s*)"inline-services"/) { %[#$1"inline-services" (
#$1  "bandwidth" ("1g" | "10g")
#$1)] }
      str
    end

    def format(str)
      str.empty? ? '' : OFFSET + str
    end

    def rule_header
      <<-EOS
require 'parslet'

module Junoser
  class Parser < Parslet::Parser
    # block with children maybe
    def b(object, *children)
      children.inject(object) {|rule, child| rule >> (space >> child).maybe }
    end

    # with an argument, and children maybe
    def a(object, arg, *children)
      b(object >> space >> arg, *children)
    end

    # choice
    def c(*objects)
      objects.inject {|rule, object| rule | object }
    end

    # sequence
    def s(*objects)
      objects.inject {|rule, object| rule >> (space >> object) }
    end

    # sequential choice
    def sc(*objects)
      (c(*objects) >> space.maybe).repeat(0)
    end

    rule(:arg)     { match('\\S').repeat(1) }
    rule(:space)   { match('\\s').repeat(1) }
    rule(:any)     { match('.').repeat(1) }
    rule(:dotted)  { match('[^. \\t\\n\\r\\f]').repeat(1) >> match('\.') >> match('[^. \\t\\n\\r\\f]').repeat(1) }
    rule(:address) { match('[0-9a-fA-F:\.]').repeat(1) }
    rule(:prefix ) { address >> (match('/') >> match('[0-9]').repeat(1)).maybe }

    root(:set)
    rule(:set) { (str('set') | str('deactivate')) >> space >> configuration }

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
