require 'helper'

class TestApplyGroupsExcept < Test::Unit::TestCase
  test 'syntax check of "apply-groups-except" statements' do
    config = %(set apply-groups-except foo\nset apply-groups-except [ foo bar ]\nset snmp apply-groups-except foo\nset snmp apply-groups-except [ foo bar ])
    assert_true Junoser::Cli.commit_check(config)
  end

  test 'transform "apply-groups-except" statements to structured form' do
    config = %(set apply-groups-except foo\nset apply-groups-except [ foo bar ]\nset snmp apply-groups-except foo\nset snmp apply-groups-except [ foo bar ])
    transformed = "apply-groups-except foo;\napply-groups-except [ foo bar ];\nsnmp {\n    apply-groups-except foo;\n    apply-groups-except [ foo bar ];\n}\n"
    assert_equal transformed, Junoser::Cli.struct(config)
  end

  test 'transform "apply-groups-except" statements to display set form' do
    config = "apply-groups-except foo;\napply-groups-except [ foo bar ];\nsnmp {\n    apply-groups-except foo;\n    apply-groups-except [ foo bar ];\n}\n"
    transformed = "set apply-groups-except foo\nset apply-groups-except foo\nset apply-groups-except bar\nset snmp apply-groups-except foo\nset snmp apply-groups-except foo\nset snmp apply-groups-except bar\n"
    assert_equal transformed, Junoser::Display::Set.new(config).transform
  end

  test 'syntax check of "apply-groups-except" statements with deactivate' do
    config = %(set apply-groups-except foo\nset apply-groups-except [ foo bar ]\nset snmp apply-groups-except foo\nset snmp apply-groups-except [ foo bar ]\ndeactivate apply-groups-except foo\ndeactivate apply-groups-except [ foo bar ]\ndeactivate snmp apply-groups-except foo\ndeactivate snmp apply-groups-except [ foo bar ])
    assert_true Junoser::Cli.commit_check(config)
  end

  test 'transform "apply-groups-except" statements to structured form with deactivate' do
    config = %(set apply-groups-except foo\nset apply-groups-except [ foo bar ]\nset snmp apply-groups-except foo\nset snmp apply-groups-except [ foo bar ]\ndeactivate apply-groups-except foo\ndeactivate apply-groups-except [ foo bar ]\ndeactivate snmp apply-groups-except foo\ndeactivate snmp apply-groups-except [ foo bar ])
    transformed = "inactive: apply-groups-except foo;\ninactive: apply-groups-except [ foo bar ];\nsnmp {\n    inactive: apply-groups-except foo;\n    inactive: apply-groups-except [ foo bar ];\n}\n"
    assert_equal transformed, Junoser::Cli.struct(config)
  end

  test 'transform "apply-groups-except" statements to display set form with deactivate' do
    config = "inactive: apply-groups-except foo;\ninactive: apply-groups-except [ foo bar ];\nsnmp {\n    inactive: apply-groups-except foo;\n    inactive: apply-groups-except [ foo bar ];\n}\n"
    transformed = "set apply-groups-except foo\ndeactivate apply-groups-except foo\nset apply-groups-except foo\ndeactivate apply-groups-except foo\nset apply-groups-except bar\ndeactivate apply-groups-except bar\nset snmp apply-groups-except foo\ndeactivate snmp apply-groups-except foo\nset snmp apply-groups-except foo\ndeactivate snmp apply-groups-except foo\nset snmp apply-groups-except bar\ndeactivate snmp apply-groups-except bar\n"
    assert_equal transformed, Junoser::Display::Set.new(config).transform
  end
end
