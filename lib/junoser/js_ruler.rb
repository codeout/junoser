module Junoser
  class JsRuler

    def initialize(input)
      @rule = input
      @sequence = 0
    end

    def sequence
      @sequence += 1
    end

    def to_rule
      rule_header << rule.gsub(/^/, '  ') << rule_footer
    end

    def rule
      str = @rule.read
      str = str.split(/\n/).map {|l| format(process_line(l))}.join("\n")
      finalize(str)
    end


    private

    def process_line(str)
      remove_undefined_variables(str)
      process_common_syntax(str)
      process_argument_syntax(str)
      process_structural_syntax(str)
      process_word(str)
      process_reserved_word(str)
      process_comment(str)

      str
    end

    def remove_undefined_variables(str)
      str.gsub! '.as(:oneline)', ''

      # "$junos-interface-unit" |
      str.gsub! /"\$[\w-]+" \| /, ''

      str
    end

    def process_common_syntax(str)
      # rule(:foo) do  ->  foo(...args) {
      str.gsub!(/^rule\(:(\S+)\) do/) {"#$1(...args) { return_next_line"}
      # end  ->  }
      str.gsub!(/^(\s*)end$/) {"#$1}"}

      # arg.as(:arg) (  ->  {"arg":
      str.gsub! /arg\.as\(:arg\) \(/, '{"arg":'
      # arg.as(:arg)  ->  {"arg": null}
      str.gsub! /arg.as\(:arg\)/, '{"arg": null}'
      # ("foo" | "bar").as(:arg) (  ->  {"(bar|baz)":
      str.gsub!(/\(([^)]+)\)\.as\(:arg\) \(/) {"{\"(#{$1.gsub('"', '').split(' | ').join('|')})\":"}
      # enum(("foo" | "bar")).as(:arg) (  ->  {"(bar|baz)":  # TODO: support "enum" in the middle of line
      str.gsub!(/enum\(\(([^)]+)\)\)\.as\(:arg\) \(/) {"{\"(#{$1.gsub('"', '').split(' | ').join('|')})\":"}

      str.gsub! '.as(:arg)', ''

      # any  ->  "any"

      # c(  ->  {
      str.gsub!(/^(\s*)c\(/) {"#$1{"}

      # foo  /* doc */,  ->  foo()  /* doc */,
      str.gsub!(%r|^(\s*)(?!arg)(\w+)(  /\* (.*) \*/,?)$|) {"#$1this.#$2()#$3"}
      # foo,  ->  foo(),
      str.gsub!(%r|^(\s*)(?!arg)(\w+)(,?)$|) {"#$1this.#$2()#$3"}

      # )  ->  }
      str.gsub!(/^(\s+)\)/) {"#$1}"}

      str
    end

    def process_argument_syntax(str)
      # "foo" (("bar" | "baz")) (  ->  "foo(bar|baz)": {
      # "foo" enum(("bar" | "baz")) (  ->  "foo(bar|baz)": {  # TODO: support "enum" in the middle of line
      str.gsub!(/^(\s*)"(\S+)" (?:enum)?\(\((.*)\)\) \(/) {"#$1\"#$2(#{$3.gsub('"', '').split(' | ').join('|')})\": {"}
      # "foo" arg (  ->  "foo(arg)": {
      str.gsub!(/^(\s*)"(\S+)" arg \(/) {"#$1\"#$2(arg)\": {"}

      # "foo" (... | arg)  /* doc */  ->  "foo": "arg"
      str.gsub!(%r|^(\s*)"(\S+)" \(.* \| arg ?.*\)  /\* (.*) \*/(,?)$|) {"#$1\"#$2 | #$3\": arg#$4"}

      # "foo" (... | arg) (  /* doc */  ->  "foo(arg)": {
      str.gsub!(%r|^(\s*)"(\S+)" \(.* \| arg ?.*\) \(  /\* (.*) \*/$|) {"#$1\"#$2(arg) | #$3\": {"}
      # "foo" (... | arg) (  ->  "foo(arg)": {
      str.gsub!(%r|^(\s*)"(\S+)" \(.* \| arg ?.*\) \($|) {"#$1\"#$2(arg)\": {"}

      # "foo" (arg | ...)  /* doc */  ->  "foo": "arg"
      str.gsub!(%r|^(\s*)"(\S+)" \(arg ?.*\)  /\* (.*) \*/(,?)$|) {"#$1\"#$2 | #$3\": arg#$4"}

      # "foo" (arg | ...) (  /* doc */  ->  "foo(arg)": {
      str.gsub!(%r|^(\s*)"(\S+)" \(arg ?.*\) \(  /\* (.*) \*/(,?)$|) {"#$1\"#$2(arg) | #$3\": {#$4"}

      # "foo" ("bar" | "baz") (  /* doc */  ->  "foo(bar|baz)": {
      str.gsub!(%r|^(\s*)"(\S+)" \("([^)]+)"\) \(  /\* (.*) \*/$|) {"#$1\"#$2(#{$3.split('" | "').join('|')}) | #$4\": {"}
      # "foo" ("bar" | "baz") (  ->  "foo(bar|baz)": {
      str.gsub!(%r|^(\s*)"(\S+)" \("([^)]+)"\) \($|) {"#$1\"#$2(#{$3.split('" | "').join('|')})\": {"}

      # "foo" ("bar" | "baz") /* doc */,  ->  "foo": ["bar", "baz"],
      str.gsub!(%r|^(\s*)"(\S+)" \(([^)]+)\)  /\* (.*) \*/(,?)$|) {"#$1\"#$2 | #$4\": [#{$3.split(' | ').join(', ')}]#$5"}
      # "foo" ("bar" | "baz"),  ->  "foo": ["bar", "baz"],
      str.gsub!(%r|^(\s*)"(\S+)" \(([^)]+)\)(,?)$|) {"#$1\"#$2\": [#{$3.split(' | ').join(', ')}]#$4"}

      # "foo" enum(("bar" | "baz"))  ->  "foo": new Enumeration(["bar", "baz"])
      str.gsub!(/^(\s*)("\S+") enum\(\((.*)\)\)/) {"#$1#$2: new Enumeration(#{$3.gsub('"', '').split(' | ')})"}

      # "foo" arg  /* doc */,  ->  "foo | doc": "arg",
      str.gsub!(%r|^(\s*)"([^"]+)" arg  /\* (.*) \*/(,?)$|) {"#$1\"#$2 | #$3\": \"arg\"#$4"}
      # "foo" arg,  ->  "foo": "arg",
      str.gsub!(%r|(\s*)"([^"]+)" arg(,?)$|) {"#$1\"#$2\": \"arg\"#$3"}

      # "foo" ipaddr,  -> "foo": this.ipaddr(),
      str.gsub!(%r|(\s*)"([^"]+)" ipaddr(,?)$|) {"#$1\"#$2\": this.ipaddr()#$3"}

      str
    end

    def process_structural_syntax(str)
      # "foo" (  /* doc */  ->  "foo | doc": (...args) => {
      str.gsub!(%r|^(\s*)"(\S+)" \(  /\* (.*) \*/|) {"#$1\"#$2 | #$3\": {"}
      # "foo" (  ->  "foo": (...args) => {
      str.gsub!(%r|^(\s*)"(\S+)" \($|) {"#$1\"#$2\": {"}

      # "foo" arg (  /* doc */  ->  "foo | doc": (...args) => {
      str.gsub!(%r|^(\s*)"(\S+)" arg \(  /\* (.*) \*/|) {"#$1\"#$2 | #$3\": {"}

      str
    end

    def process_word(str)
      # arg  ->  "arg"
      # (arg)  ->  "arg"
      # enum(arg)  ->  "arg"
      str.gsub!(/ ((?!arg\w)(arg)|(enum)?\(arg\))/, ' "arg"')

      # "foo"  /* doc */,  ->  "foo | doc": null,
      str.gsub!(%r|^(\s*)"([^"]+)"  /\* (.*) \*/(,?)$|) {"#$1\"#$2 | #$3\": null#$4"}
      # "foo",  ->  "foo": null,
      str.gsub!(%r|^(\s*)"([^"]+)"(,?)$|) {"#$1\"#$2\": null#$3"}

      # ("foo" | "bar")  ->  ["foo", "bar"]
      str.gsub!(/^(\s*) \(+("[^"]+(?:" \| "[^"]+)*")\)+(,?)$/) do
        comma = $3
        "#$1#{$2.gsub('"', '').split(' | ')}#{comma}"
      end

      # enum(("bar" | "baz"))  ->  "foo": new Enumeration(["bar", "baz"])
      str.gsub!(/^(\s*)enum\(\((.*)\)\)/) {"#$1new Enumeration(#{$2.gsub('"', '').split(' | ')})"}

      # (arg | "foo")  ->  ["arg", "foo"]
      str.gsub!(/^(\s*) \(arg( \| "[^"]+")+\)/) {"#$1[\"arg\"#{$2.split(' | ').join(', ')}]"}

      str
    end

    def process_reserved_word(str)
      # ieee-802.3ad  -> 802.3ad
      str.gsub! 'ieee-802.3ad', '802.3ad'

      str
    end

    def process_comment(str)
      # %  ->  %%
      str.gsub! '%', '' % %''

      # "foo": ...  /* doc */,  ->  "foo | doc": ...,
      str.gsub!(%r|^(\s*)"([^"]+)": (.*)  /\* (.*) \*/(,?)$|) {"#$1\"#$2 | #$4\": #$3#$5"}

      str
    end

    def finalize(lines)
      lines = balance_parenthesis(lines)
      objectize_arg_of_s(lines)

      # return_next_line
      #   ...
      #
      # ->
      #
      # return ...
      lines.gsub!(/return_next_line\n(\s*)/m) {"\n#$1return "}

      # {
      #   {
      #
      # ->
      #
      # {
      #   "null_1": {
      lines.gsub!(/([{,]\n\s*){/m) {"#$1\"null_#{sequence}\": {"}

      # {
      #   foo()
      #
      # ->
      #
      # {
      #   "null_1": foo()
      lines.gsub!(/([{,]\n\s*)([^ "(]+)/m) {"#$1\"null_#{sequence}\": #$2"}
    end

    def balance_parenthesis(lines)
      # Fixes
      lines.gsub! 'Timeslots (1..24;', 'Timeslots (1..24);'

      count = 0
      target = nil
      buf = ''
      stack = []

      lines.each_char do |c|
        case c
        when '('
          count += 1
          stack << target
          target = count

          buf << c
        when '{'
          count += 1

          buf << c
        when ')'
          count -= 1
          target = stack.pop

          buf << c
        when '}'
          count -= 1

          if target && count == target - 1
            target = stack.pop

            buf << ')'
          else
            buf << c
          end
        else
          buf << c
        end
      end

      buf
    end

    def objectize_arg_of_s(lines)
      # s(  ->  s({
      lines.gsub!(/^( *(?:return|\S+:)? +)s\($/m) {"#$1this.s({"}

      # )  ->  })
      lines.gsub!(/^( *)\)$/m) {"#$1})"}

      lines
    end

    def rule_header
      <<~EOS
        class Enumeration {
          constructor(list) {
            this.list = list;
            this.children = [];
          }

          map(callback) {
            // NOTE: This is a bit hacky but assuming that it's called like "this.children.map((node) => node.name)"
            return this.list;
          }

          find(callback) {
            // NOTE: This is a bit hacky but assuming that it's called like "this.children.find((node) => node.name === string)"
            return;
          }

          forEach(callback) {
            return this.list.forEach(callback);
          }

          keywords() {
            return this.list;
          }
        }

        class Sequence {
          constructor(list) {
            this.list = list;
          }

          get(depth) {
            return this.list[depth];
          }
        }

        class JunosSchema {
          any() {
            return "any";
          }

          s(obj) {
            const list = Object.entries(obj).map(([key, value]) => ({[key]: value}));
            return new Sequence(list);
          }

      EOS
    end

    def rule_footer
      <<~EOS

        }

        module.exports = {schema:new JunosSchema(), Enumeration: Enumeration, Sequence: Sequence};
      EOS
    end
  end
end
