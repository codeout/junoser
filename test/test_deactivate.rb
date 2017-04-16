require 'test-unit'
require 'junoser'

class TestDeactivate < Test::Unit::TestCase
  test 'display set form with deactivated description' do
    config = %(set interfaces ge-0/0/0 description "foo"\ndeactivate interfaces ge-0/0/0 description)
    assert_true Junoser::Cli.commit_check(config)
  end

  test 'invalid display set form with deactivated description' do
    config = %(set interfaces ge-0/0/0 description "foo"\ndeactivate interfaces ge-0/0/0 description "other")
    assert_false Junoser::Cli.commit_check(config)
  end

  test 'structured form with deactivated description' do
    config = %(interfaces {\n    ge-0/0/0 {\n        inactive: description "foo";    }\n})
    assert_true Junoser::Cli.commit_check(config)
  end
end
