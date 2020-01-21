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
end
