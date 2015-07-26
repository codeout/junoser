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
      str.gsub! '"as-number" arg', 'arg'
      str.gsub! '"confederation-as" arg', 'arg'
      str.gsub! '"equal-literal"', '"="'
      str.gsub! '"plus-literal"', '"+"'
      str.gsub! '"minus-literal"', '"-"'

      str.gsub!(/\((.*) \| "name"\)/) { "(#$1 | arg)" }
      str.gsub! '"vlan" ("id-name" | "all")', '"vlan" ("all" | arg)'
      str.gsub!(/("ssh-\S+") arg/) { "#$1 (quote | arg)" }
      str.gsub! '"metric-value" arg', 'arg'
      str.gsub! '"limit-threshold" arg', 'arg'
      str.gsub! '"filename" arg', 'arg'
      str.gsub! '"description" arg', '"description" (quote | arg)'
      str.gsub! '"as-path-prepend" arg', '"as-path-prepend" (quote | arg)'


      str.gsub!(/^(\s*)"inline-services"/) do
        format(['"inline-services" (',
                '  "bandwidth" ("1g" | "10g")',
                ')'], $1)
      end
      str.gsub!(/^(\s*)"ieee-802.3ad" \(\s*sc\(\s*"lacp" \(\s*sc\(/) do
        format(['"802.3ad" (',
                '  sc(',
                '    arg,',
                '    "lacp" (',
                '      sc(',
                '        "force-up",'], $1)
      end
      str.gsub!(/^(\s*)"as-path" \(\s*sc\(\s*"path" arg/) do
        format(['"as-path" (',
                '  sc(',
                '    arg'], $1)
      end
      str.gsub!(/^(\s*)"as-path" arg \(\s*sc\(\s*"path" arg\s*\)/) do
        format(['"as-path" arg (',
                '  sc(',
                '    quote,',
                '    arg',
                '  )'], $1)
      end

      str.gsub!(/^rule\(:regular_expression\) do\s*((?!end).)*\s*end/) do
        "rule(:regular_expression) do
  (quote | arg).as(:arg)
end"
      end

      str.gsub!(/("next-hop" \(\s*sc\(\s*c\(\s*[^)]*)"address" \(\s*ipaddr\s*\)/) { "#{$1}ipaddr" }

      %w[metric metric2 metric3 metric4 tag tag2 preference preference2 color color2 local-preference].each do |key|
        str.gsub!(/^(\s*"#{key}" \(\s*sc\(\s*c\(\s*)"#{key}" arg/) { "#{$1}arg" }
      end

      str.gsub!(/(s\(\s*)"address" \(\s*arg\s*\)/) { "#{$1}arg" }
      str.gsub!(/^(\s*"idle-timeout" \(\s*sc\(\s*c\(\s*"forever",\s*)"timeout" arg/) { "#{$1}arg" }

      str = omit_label(str, 'contents', 'syslog_object')
      str = omit_label(str, 'interface', 'cos_interfaces_type')
      str = omit_label(str, 'interface', 'ir_interfaces_type')
      str = omit_label(str, 'interface', 'interfaces_type')
      str = omit_label(str, 'client-address-list', 'client_address_object')
      str = omit_label(str, 'prefix-list-item', 'prefix_list_items')
      str = omit_label(str, 'instance', 'juniper_routing_instance')
      str = omit_label(str, 'vlan', 'vlan_type')

      str.gsub!(/"icmp"(.*)"icmp6"/) { %["icmpv6"#$1"icmp"] }
      str.gsub!(/"http"(.*)"https"/) { %["https"#$1"http"] }
      str.gsub!(/"snmp"(.*)"snmptrap"/) { %["snmptrap"#$1"snmp"] }

      str
    end

    def omit_label(str, label, content)
      str.gsub(/(\s*)"#{label}" \(\s*#{content}\s*\)/) { "#{$1}#{content}" }
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

    # sequence
    def s(*objects)
      # TODO:  eval "minOccurs" attribute of choice element
      objects.inject {|rule, object| rule >> (space >> object).maybe }
    end

    # sequential choice
    def sc(*objects)
      (c(*objects) >> space.maybe).repeat(0)
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
    rule(:set) { (str('set') | str('deactivate')) >> space >> configuration.as(:config) >> comment.maybe }

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
