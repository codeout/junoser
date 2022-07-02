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
      str = remove_comments(str)
      str = process_reserved_element(str)
      str.split(/\n/).map { |l| format(process_line(l)) }.join("\n")
    end

    private

    def remove_comments(str)
      str.gsub(%r(\s*/\*.*\*/), '')
    end

    def process_line(str)
      return str if str =~ /^(.* do|end)$/

      str.gsub!(/("[^"]+")/) { "str(#{$1})" } # "foo" -> str("foo")

      str.gsub!(/^(\s*)arg(\.as\(:\S+\))? \($/) { "#{$1}b(arg#{$2}," } # arg ( -> b(arg,
      str.gsub!(/^(\s*)(str\(\S+\)) ([^ \t\n\r\f(|,]+)(\.as\(:\S+\))?(,?)$/) { "#{$1}a(#{$2}, #{$3})#{$4}#{$5}" } # str("foo") bar -> a(str("foo"), bar)
      str.gsub!(/^(\s*)(str\(\S+\)) (enum)?\((.*)\)(,?)$/) { "#{$1}a(#{$2}, #{$3}#{$4})#{$5}" } # str("foo") (a | b) -> a(str("foo"), a | b)

      str.gsub!(/^(\s*)(str\(\S+\)) \($/) { "#{$1}b(#{$2}," } # str("foo") ( -> b(str("foo"),
      str.gsub!(/^(\s*)(enum)?(\(.*\))(\.as\(:\S\))? \($/) { "#{$1}b(#{$2}#{$3}#{$4}," } # (a | b) ( -> b((a | b),
      str.gsub!(/^(\s*)(str\(\S+\)) ([^ \t\n\r\f(|,]+) \($/) { "#{$1}b(a(#{$2}, #{$3})," } # str("foo") bar ( -> b(a(str("foo"), bar),
      str.gsub!(/^(\s*)(str\(\S+\)) (enum)?\((.*)\) \($/) { "#{$1}a(#{$2}, #{$3}#{$4}," } # str("foo") (a | b) ( -> a(str("foo"), a | b,

      str
    end

    def process_reserved_element(str)
      str.gsub! /"\$\S+"/, 'arg'

      str.gsub! /"groups" \(\s*s\(\s*any\s*\)\s*\)/, 'a("groups", arg, configuration)'

      str.gsub! '"equal-literal"', '"="'
      str.gsub! '"plus-literal"', '"+"'
      str.gsub! '"minus-literal"', '"-"'

      #
      # Statements can be quoted
      #
      str.gsub!(/("ssh-\S+") arg/) { "#{$1} (quote | arg)" }
      str.gsub! '"message" arg', '"message" (quote | arg)'
      str.gsub! '"description" arg', '"description" (quote | arg)'
      str.gsub! '"as-path-prepend" arg', '"as-path-prepend" (quote | arg)'

      str.gsub!(/^(\s*)"as-path" arg \(\s*c\(\s*arg/) do
        format(['"as-path" arg (',
                '  c(',
                '    quote | arg'], $1)
      end

      str.gsub!(/^rule\(:regular_expression\) do\s.*?\s*end/) do
        <<~EOS
          rule(:regular_expression) do
            (quote | arg).as(:arg)
          end
        EOS
      end

      str.gsub!(/^rule\(:login_user_object\) do\s*arg\.as\(:arg\) \(\s*c\(\s*"full-name" arg,/) do
        <<~EOS
          rule(:login_user_object) do
            arg.as(:arg) (
              sc(
                "full-name" (quote | arg),
        EOS
      end

      str.gsub!(/^(\s*)"location" arg,\s*"contact" arg,/) do
        format(['"location" (quote | arg),',
                '"contact" (quote | arg),'], $1)
      end

      str.gsub!(/^(\s*)"as-path" \(\s*c\(\s*"path" arg/) do
        format(['"as-path" (',
                '  c(',
                '    "path" (quote | arg)'], $1)
      end

      str.gsub!(/^(\s*)prefix_list_items,\s*"apply-path" arg/) do
        format(['"apply-path" (quote | arg),',
                'prefix_list_items'], $1)
      end

      #
      # "arg" matches anything so move to the end
      #
      str.gsub!(/arg \| (".*")/) { "#{$1} | arg" }
      str.gsub!(/^(\s*)c\(\s*arg,$/) { "#{$1}ca(" }
      str.gsub!(/(rule\(:control_route_filter_type\) do\s*)s\(\s*arg,/) { "#{$1}b(" }
      str.gsub!(/(rule\(:control_source_address_filter_type\) do\s*)s\(\s*arg,/) { "#{$1}b(" }
      str.gsub!(/^(rule\(:trace_file_type\) do\s*)ca\(/) { "#{$1}sca(" }

      str.gsub!(/^(rule\(:archive_object\) do\s*)c\(/) { "#{$1}sc(" }
      str.gsub!(/^(rule\(:server_group_type\) do\s*)c\(\s*c\(\s*arg\s*\)\s*\)/) { "#{$1}s(arg, arg)" }

      str.gsub!(/^(rule\(:rib_group_inet_type\) do)\s*c\(\s*arg/) do
        format([$1,
                '  ca(',
                '    a(arg, arg)'], '')
      end

      # Fix overkill
      str.gsub!(/^(\s*)"priority" \(\s*ca\(\s*arg\s*\)/) do
        format(['"priority" (',
                '  a(arg, arg)', $1])
      end

      #
      # Longer pattern first
      #
      # covers:
      #   "inet" | "inet6"
      #
      #   and even
      #
      #   "inet",
      #   "inet6"
      str.gsub!(/"cspf"(.*\s*.*)"cspf-link"/) { %["cspf-link"#{$1}"cspf"] }
      str.gsub!(/"http"(.*\s*.*)"https"/) { %["https"#{$1}"http"] }
      str.gsub!(/"inet"(.*\s*.*)"inet6"/) { %["inet6"#{$1}"inet"] }
      str.gsub!(/"icmp"(.*\s*.*)"icmp6"/) { %["icmp6"#{$1}"icmp"] }
      str.gsub!(/"icmp"(.*\s*.*)"icmpv6"/) { %["icmpv6"#{$1}"icmp"] }
      str.gsub!(/"snmp"(.*\s*.*)"snmptrap"/) { %["snmptrap"#{$1}"snmp"] }
      str.gsub!(/"ospf"(.*\s*.*)"ospf3"/) { %["ospf3"#{$1}"ospf"] }
      str.gsub! '"tls1" | "tls11" | "tls12"', '"tls11" | "tls12" | "tls1"'
      str.gsub!(/("group1" \| "group2" \| "group5") \| ([^)]+)/) { "#{$2} | #{$1}"}

      %w[ccc ethernet-over-atm tcc vpls bridge].each do |encap|
        str.gsub!(/"ethernet"(.*)"ethernet-#{encap}"/) { %["ethernet-#{encap}"#{$1}"ethernet"] }
      end

      str.gsub!(/^(\s*)"path" arg \(\s*c\(\s*sc\(\s*"abstract",\s*c\(\s*"loose",\s*"loose-link",\s*"strict"\s*\)\s*\)\.as\(:oneline\)/) do
        format(['"path" arg (',
                '  c(',
                '    b(',
                '      ipaddr,',
                '      c(',
                '        "abstract",',
                '        c(',
                '          "loose-link",',
                '          "loose",',
                '          "strict"',
                '        )',
                '      ).as(:oneline)',
                '    )', $1])
      end

      #
      # Fix .xsd: Elements without "nokeyword" flag
      #
      str.gsub!(/\((.*) \| "name"\)/) { "(#{$1} | arg)" }
      str.gsub! '"vlan" ("all" | "vlan-name")', '"vlan" ("all" | arg)'
      str.gsub!(/\((.*) \| "vlan-id"\)/) { "(#{$1} | arg)" }

      %w[filename].each do |key|
        str.gsub! %["#{key}" arg], 'arg'
      end

      # "filename" fix above leaves "arg". Move to the end
      str.gsub!(/^(rule\(:esp_trace_file_type\) do\s*)c\(\s*arg,/) { "#{$1}ca(" }

      # Fix .xsd: system processes dhcp is valid on some platforms
      str.gsub! '"dhcp-service" (', '("dhcp-service" | "dhcp") ('

      # Fix .xsd: "icmpv6" is also acceptable
      str.gsub! '"icmp6" |', '"icmp6" | "icmpv6" |'

      #
      # Fix .xsd: "arg" is missing
      #
      str.gsub!(/"route-filter" (\(\s*control_route_filter_type\s*\))/) { %["route-filter" arg #{$1}.as(:oneline)] }
      str.gsub!(/"source-address-filter" (\(\s*control_source_address_filter_type\s*\))/) { %["source-adress-filter" arg #{$1}.as(:oneline)] }
      %w[file].each do |key|
        str.gsub!(/^(\s*"#{key}" \(\s*)c\(\s*arg,/) { "#{$1}sca(" }
      end

      # Fix .xsd: Unnecessary "arg" is added
      %w[exact longer orlonger].each do |key|
        str.gsub!(/^(\s*"#{key}") arg/) { "#{$1}" }
      end

      # Fix .xsd: "ieee-802.3ad" is invalid
      str.gsub! '"ieee-802.3ad"', '"802.3ad"'

      # Fix .xsd: "class-of-service interfaces all unit * classifiers exp foo"
      str.gsub!(/^(\s*)sc\(\s*\("default"\)\s*\)/) do
        format(['c(',
                '  ("default" | arg)',
                ')'], $1)
      end

      # Fix .xsd: "from-zone" arg is also required
      str.gsub!(/^(\s*)"policy" \(\s*s\(\s*arg,\s*"to-zone-name" arg,\s*c\(\s*"policy" \(\s*policy_type\s*\)\s*\)/) do
        format(['b(s("from-zone", arg, "to-zone", arg),',
                '    b("policy", policy_type',
               ], $1)
      end

      # Fix .xsd: "members" accepts [ foo bar ]
      str.gsub! '"members" arg', '"members" any'

      # Fix .xsd: "term_object" accepts multiple conditions
      str.gsub!(/^(rule\(:term_object\) do\s*arg\.as\(:arg\) \(\s*)c\(/) { "#{$1}sc(" }

      # Fix .xsd: keywords "dest-nat-rule-match", "src-nat-rule-match", "static-nat-rule-match" are wrong
      str.gsub!(/"(dest|src|static)-nat-rule-match"/) { '"match"' }

      # Fix .xsd: "snmp system-name" should be "snmp name"
      str.gsub! '"system-name" arg', '"name" (quote | arg)'

      str
    end

    def format(str, offset = OFFSET)
      case str
      when String
        str.empty? ? '' : offset + str
      when Array
        str.map { |s| s.empty? ? '' : offset + s.to_s }.join("\n")
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
        passed & parse_line(line, lines_without_deactivate)
      end
    end

    def parse_line(line, lines_without_deactivate)
      if line =~ /^deactivate/
        if lines_without_deactivate.grep(/^\#{line.sub(/^deactivate/, 'set')}/).empty?
          $stderr.puts %(Corresponding "set" statement is not found:  \#{line})
          return false
        else
          return true
        end
      end

      begin
        # .xsd doesn't include "apply-groups"
        if line =~ /(.*)\\s+apply-groups(-except)?\\s+(\\S+|\\[.*\\])$/
          return \$1 == 'set' ? true : parse(\$1)
        end

        parse line
        true
      rescue Parslet::ParseFailed
        $stderr.puts "Invalid syntax:  \#{line}"
        false
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

    def enum(object)
      (object.as(:enum))
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
