require 'helper'

class TestApplyGroups < Test::Unit::TestCase
  test 'syntax check of group definitions' do
    config = %(set groups foo snmp location "foo"\nset groups bar snmp location bar\nset groups baz snmp location baz\ndeactivate groups baz snmp location baz)
    assert_true Junoser::Cli.commit_check(config)
  end

  test 'transform group definitions to structured form' do
    config = %(set groups foo snmp location "foo"\nset groups bar snmp location bar\nset groups baz snmp location baz\ndeactivate groups baz snmp location baz)
    transformed = "groups foo {\n    snmp {\n        location \"foo\";\n    }\n}\ngroups bar {\n    snmp {\n        location bar;\n    }\n}\ngroups baz {\n    snmp {\n        inactive: location baz;\n    }\n}\n"
    assert_equal transformed, Junoser::Cli.struct(config)
  end

  test 'transform group definitions to display set form' do
    config = "groups foo {\n    snmp {\n        location \"foo\";\n    }\n}\ngroups bar {\n    snmp {\n        location bar;\n    }\n}\ngroups baz {\n    snmp {\n        inactive: location baz;\n    }\n}\n"
    transformed = "set groups foo snmp location \"foo\"\nset groups bar snmp location bar\nset groups baz snmp location baz\ndeactivate groups baz snmp location baz\n"
    assert_equal transformed, Junoser::Display::Set.new(config).transform
  end

  test 'syntax check of "apply-groups" statements' do
    config = %(set apply-groups foo\nset apply-groups [ foo bar ]\nset snmp apply-groups foo\nset snmp apply-groups [ foo bar ])
    assert_true Junoser::Cli.commit_check(config)
  end

  test 'transform "apply-groups" statements to structured form' do
    config = %(set apply-groups foo\nset apply-groups [ foo bar ]\nset snmp apply-groups foo\nset snmp apply-groups [ foo bar ])
    transformed = "apply-groups foo;\napply-groups [ foo bar ];\nsnmp {\n    apply-groups foo;\n    apply-groups [ foo bar ];\n}\n"
    assert_equal transformed, Junoser::Cli.struct(config)
  end

  test 'transform "apply-groups" statements to display set form' do
    config = "apply-groups foo;\napply-groups [ foo bar ];\nsnmp {\n    apply-groups foo;\n    apply-groups [ foo bar ];\n}\n"
    transformed = "set apply-groups foo\nset apply-groups foo\nset apply-groups bar\nset snmp apply-groups foo\nset snmp apply-groups foo\nset snmp apply-groups bar\n"
    assert_equal transformed, Junoser::Display::Set.new(config).transform
  end

  test 'syntax check of "apply-groups" statements with deactivate' do
    config = %(set apply-groups foo\nset apply-groups [ foo bar ]\nset snmp apply-groups foo\nset snmp apply-groups [ foo bar ]\ndeactivate apply-groups foo\ndeactivate apply-groups [ foo bar ]\ndeactivate snmp apply-groups foo\ndeactivate snmp apply-groups [ foo bar ])
    assert_true Junoser::Cli.commit_check(config)
  end

  test 'transform "apply-groups" statements to structured form with deactivate' do
    config = %(set apply-groups foo\nset apply-groups [ foo bar ]\nset snmp apply-groups foo\nset snmp apply-groups [ foo bar ]\ndeactivate apply-groups foo\ndeactivate apply-groups [ foo bar ]\ndeactivate snmp apply-groups foo\ndeactivate snmp apply-groups [ foo bar ])
    transformed = "inactive: apply-groups foo;\ninactive: apply-groups [ foo bar ];\nsnmp {\n    inactive: apply-groups foo;\n    inactive: apply-groups [ foo bar ];\n}\n"
    assert_equal transformed, Junoser::Cli.struct(config)
  end

  test 'transform "apply-groups" statements to display set form with deactivate' do
    config = "inactive: apply-groups foo;\ninactive: apply-groups [ foo bar ];\nsnmp {\n    inactive: apply-groups foo;\n    inactive: apply-groups [ foo bar ];\n}\n"
    transformed = "set apply-groups foo\ndeactivate apply-groups foo\nset apply-groups foo\ndeactivate apply-groups foo\nset apply-groups bar\ndeactivate apply-groups bar\nset snmp apply-groups foo\ndeactivate snmp apply-groups foo\nset snmp apply-groups foo\ndeactivate snmp apply-groups foo\nset snmp apply-groups bar\ndeactivate snmp apply-groups bar\n"
    assert_equal transformed, Junoser::Display::Set.new(config).transform
  end
end
