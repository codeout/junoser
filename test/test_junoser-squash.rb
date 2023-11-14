require 'pathname'

require 'helper'
require 'junoser/squash'


class TestCommentLine < Test::Unit::TestCase
  test 'check subcommand function' do
    config = <<-EOS
set interfaces em0 unit 0 family inet address 192.0.2.1/32
set interfaces em0 unit 0 family inet
set interfaces em100 unit 0 family inet
set interfaces em100 unit 0 family inet address 192.0.2.1/32
    EOS

    assert_equal('set interfaces em0 unit 0 family inet address 192.0.2.1/32
set interfaces em100 unit 0 family inet
set interfaces em100 unit 0 family inet address 192.0.2.1/32', Junoser::Squash.new(config).transform)
  end

  test 'check argument order' do
    config = <<-EOS
set protocols bgp group foo neighbor 10.0.0.10
set protocols bgp group foo neighbor 10.0.0.1
    EOS

    assert_equal('set protocols bgp group foo neighbor 10.0.0.10
set protocols bgp group foo neighbor 10.0.0.1', Junoser::Squash.new(config).transform)
  end

  test 'check delete function' do
    config = <<-EOS
set interfaces em0 unit 0 family inet address 192.0.2.0/32
set interfaces em10 unit 10 family inet address 192.0.2.0/32
set interfaces em10 unit 10 family inet mtu 1500
set interfaces em10 unit 20
set interfaces em100 unit 100 family inet address 192.0.2.0/32
set interfaces em100 unit 200 family inet6
delete interfaces em0 unit 0 family inet address 192.0.2.0/32
delete interfaces em10 unit 10
delete interfaces em100 unit 200

set routing-options static route 10.0.0.0/24 next-hop 172.16.0.1
set routing-options static route 10.0.1.0/24 next-hop 172.16.0.1
set routing-options static route 10.0.2.0/24 next-hop 172.16.0.1
set routing-options static route 10.0.3.0/24 community 65000:100
delete routing-options static route 10.0.0.0/24
delete routing-options static route 10.0.1.0/24 next-hop
delete routing-options static route 10.0.2.0/24 next-hop 172.16.0.1
delete routing-options static route 10.0.3.0/24 community 65000:100
    EOS

    # TODO: On Junos platform, those lines are completely deleted but junoser-squash cannot do this for now
    # set routing-options static
    # set routing-options static route 10.0.1.0/24
    # set routing-options static route 10.0.2.0/24
    # set routing-options static route 10.0.3.0/24

    assert_equal('set interfaces em0 unit 0 family inet
set interfaces em10
set interfaces em10 unit 20
set interfaces em100 unit 100 family inet address 192.0.2.0/32
set routing-options static
set routing-options static route 10.0.1.0/24
set routing-options static route 10.0.2.0/24
set routing-options static route 10.0.3.0/24', Junoser::Squash.new(config).transform)
  end

  test 'check insert statement' do
    config = 'set policy-options policy-statement foo term bar then accept
set policy-options policy-statement foo term baz then accept
insert policy-options policy-statement foo term baz before term bar'

    assert_equal('set policy-options policy-statement foo term baz then accept
set policy-options policy-statement foo term bar then accept', Junoser::Squash.new(config).transform)

    config = 'set policy-options policy-statement foo term bar then accept
set policy-options policy-statement foo term baz then accept
insert policy-options policy-statement foo term bar after term baz'

    assert_equal('set policy-options policy-statement foo term baz then accept
set policy-options policy-statement foo term bar then accept', Junoser::Squash.new(config).transform)

    config = 'set protocols bgp group foo export bar
set protocols bgp group foo export baz
insert protocols bgp group foo export baz before bar'

    assert_equal('set protocols bgp group foo export baz
set protocols bgp group foo export bar', Junoser::Squash.new(config).transform)

    config = 'set protocols bgp group foo export bar
set protocols bgp group foo export baz
insert protocols bgp group foo export bar after baz'

    assert_equal('set protocols bgp group foo export baz
set protocols bgp group foo export bar', Junoser::Squash.new(config).transform)
  end
end
