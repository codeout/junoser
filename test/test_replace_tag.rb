require 'helper'

class TestReplaceTag < Test::Unit::TestCase
  test 'transform structured form with "replace:" tag' do
    config = "interfaces {\n    ge-0/0/0 {\n        replace: unit 0 {\n            family inet {\n                replace: dhcp;\n            }\n        }\n    }\n}"
    pattern = /set interfaces ge-0\/0\/0 unit 0 family inet dhcp/
    assert_match pattern, Junoser::Display::Set.new(config).transform
  end
end
