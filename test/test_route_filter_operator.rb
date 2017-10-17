require 'helper'

class TestRouteFilterOperator < Test::Unit::TestCase
  test 'route filter operator' do
    config = 'set policy-options policy-statement foo term bar from route-filter 10.0.0.0/24 through 10.0.0.0/25'
    pattern = /policy-options {\s*policy-statement foo {\s*term bar {\s*from {\s*route-filter 10.0.0.0\/24 through 10.0.0.0\/25;\s*}\s*}\s*}\s*}/
    assert_match pattern, Junoser::Cli.struct(config)
  end

  test 'route filter operator with an action' do
    config = 'set policy-options policy-statement foo term bar from route-filter 10.0.0.0/24 through 10.0.0.0/25 reject'
    pattern = /policy-options {\s*policy-statement foo {\s*term bar {\s*from {\s*route-filter 10.0.0.0\/24 through 10.0.0.0\/25 reject;\s*}\s*}\s*}\s*}/
    assert_match pattern, Junoser::Cli.struct(config)
  end

  test 'route filter operator with an invalid action' do
    config = 'set policy-options policy-statement foo term bar from route-filter 10.0.0.0/24 through 10.0.0.0/25 invalid'
    assert_raise(Parslet::ParseFailed) { Junoser::Cli.struct(config) }
  end
end
