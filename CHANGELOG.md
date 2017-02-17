## 0.2.4 / 2017-02-18

* Newly supported syntax
  * system processes app-engine-virtual-machine-management-service traceoptions
  * Some platforms expect "system processes dhcp", not "system processes dhcp-service"
  * "storm-control" under family bridge
* Bug fix
  * Appropriately extract "vlan <vlan-name>"

## 0.2.3 / 2016-08-28

* Newly supported syntax
  * chassis fpc N error
  * forwarding-options sampling family mpls

## 0.2.2 / 2016-02-15

* Newly supported syntax
  * system services ssh
* Bug fix
  * choice syntax

## 0.2.1 / 2016-01-15

* Newly supported syntax
  * services flow-monitoring version9 template
* Bug fix
  * template-name
* Start CI

## 0.2.0 / 2015-12-26

* Use "choice" instead of "sequence of choices"
  * Sequence of choices comes from .xsd for NETCONF.
    It's required for XML but worthless and time wasting for CLI.
  * 150% fast!

* Many bug fixes
  * 802.3ad
  * ether-options
  * storm-control default
  * vrf-target
  * maximum-prefix teardown
  * traceoptions
  * system syslog archive
  * system login user
  * routing-options confederation
  * hold-time
  * protocols ospf area x.x.x.x stub default-metric x x
  * protocols rsvp interface xxx subscription x
  * traceoptions cspf-link
  * protocols mpls priority
  * protocols mpls label-switched-path xxx primary xxx bandwidth xxx
  * protocols xxx rib-group xxx xxx
  * protocols mpls path xxx xxx

* Newly supported syntax
  * Minimal configuration of MS-PIC/MIC based flow sampling

## 0.1.6 / 2015-10-31

* Bug fix
  * route-filter statement should be translated into one-line

## 0.1.5 / 2015-09-11

* Bug fix
  * mistakenly processed '{' and '}' in as-path string

## 0.1.4 / 2015-09-11

* Bug fix
  * missing community operator in policy-statement didn't fail

## 0.1.3 / 2015-07-26

* Newly supported syntax
  * "chassis ... sampling-instance"
  * "forwarding-options sampling instance"
  * "chassis forwarding-options"
  * "protocols layer2-control"
* Cosmetic changes on structured config translation
* Bug fix
  * "confederation-as" statement
  * "next-hop" statement
  * "junoser -v" didn't work
  * comment line handling
* Add tests

## 0.1.2 / 2015-07-14

* Bug fix

## 0.1.1 / 2015-07-14

* Now "commit_check" method returns boolean
* Bug fixes

## 0.1.0 / 2015-07-14

* First release
