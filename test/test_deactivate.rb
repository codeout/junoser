require 'helper'

class TestDeactivate < Test::Unit::TestCase
  test 'check display set form with deactivated description' do
    config = %(set interfaces ge-0/0/0 description "foo"\ndeactivate interfaces ge-0/0/0 description)
    assert_true Junoser::Cli.commit_check(config)
  end

  test 'check invalid display set form with deactivated description' do
    config = %(set interfaces ge-0/0/0 description "foo"\ndeactivate interfaces ge-0/0/0 description "other")
    assert_false Junoser::Cli.commit_check(config)
  end

  test 'check structured form with deactivated description' do
    config = %(interfaces {\n    ge-0/0/0 {\n        inactive: description "foo";    }\n})
    assert_true Junoser::Cli.commit_check(config)
  end

  test 'transform display set form with deactivated unit' do
    config = "set interfaces ge-0/0/0 unit 0 family inet dhcp\ndeactivate interfaces ge-0/0/0 unit 0"
    pattern = /interfaces ge-0\/0\/0 {\s*inactive: unit 0 {\s*family {\s*inet {\s*dhcp;\s*}\s*}\s*}\s*}/
    assert_match pattern, Junoser::Cli.struct(config)
  end

  test 'transform structured form with deactivated unit' do
    config = "interfaces {\n    ge-0/0/0 {\n        inactive: unit 0 {\n            family inet {\n                dhcp;\n            }\n        }\n    }\n}"
    pattern = /set interfaces ge-0\/0\/0 unit 0 family inet dhcp\s*deactivate interfaces ge-0\/0\/0 unit 0/
    assert_match pattern, Junoser::Display::Set.new(config).transform
  end
end

