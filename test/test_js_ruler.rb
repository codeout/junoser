# frozen_string_literal: true

require 'helper'
require 'junoser/development'
require 'stringio'

class TestJsRuler < Test::Unit::TestCase
  test 'number serial arguments of a sequence' do
    rule = <<~RULE
      rule(:path_lsp_type) do
        c(
          "priority" (  /* Preemption priorities */
          s(
            arg,
            arg
          )
        )
        )
      end
    RULE

    js = Junoser::JsRuler.new(StringIO.new(rule)).rule

    assert_not_match(/"arg":/, js)
    assert_equal 2, js.scan(/"arg_\d+": null/).uniq.size
  end
end
