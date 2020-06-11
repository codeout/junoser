# Junoser

[![Build Status](https://travis-ci.org/codeout/junoser.svg)](https://travis-ci.org/codeout/junoser)
[![Code Climate](https://codeclimate.com/github/codeout/junoser.png)](https://codeclimate.com/github/codeout/junoser)
[![Inline docs](http://inch-ci.org/github/codeout/junoser.svg)](http://inch-ci.org/github/codeout/junoser)

Junoser is a JUNOS configuration PEG parser which can be automatically generated from Juniper's netconf.xsd. (XML Schema Definition for NETCONF)

## Features

* Configuration Validation
  * Structured "show configuration" format
  * One-liner "| display set" format

* Configuration Translation
  * Inter-translation between structured form and display-set form

**NOTE**

Inter-translation from display-set form into structured form is experimental feature in this release.


## Getting Started

```zsh
$ gem install junoser
```

### Usage

#### Syntax validation

```zsh
$ junoser -c config.txt

# or

$ cat config.txt | junoser -c
```

#### Syntax translation

##### Structured form into "display set"

```zsh
$ junoser -d config.txt
set protocols bgp group ebgp-peers neighbor 192.0.2.2

# or

$ cat config.txt | junoser -d
set protocols bgp group ebgp-peers neighbor 192.0.2.2
```

##### "display set" into structured form

```zsh
$ junoser -s config.txt

# or

$ cat config.txt | junoser -s
```


## Updating parser for new directives

From [Juniper
website](https://support.juniper.net/support/downloads/), you can
download the XSD schema for the version of JunOS you want to target:

 - Junos XML API
 - Select your version
 - Application Tools
 - XML Schema for Configurator Data

Alternatively, you can retrieve the schema with Netconf:

```zsh
$ ssh -Csp 830 JUNOS netconf < example/get-schema.xml | sed -n '/^<xsd:schema/,/^<\/xsd:schema/p' > junos-XXX.xsd
```

Put it in `tmp/`, update `xsd_path` in `Rakefile` and run:

```zsh
$ bundle exec rake build:config build:rule
```

Alternatively, you may look in `example/` for some prebuilt rules
file. If you want to use them, copy one to `tmp/rules.rb` and run:

```zsh
$ bundle exec rake build:rule
```

## Contributing

Please report issues or enhancement requests to [GitHub issues](https://github.com/codeout/junoser/issues).
For questions or feedbacks write to my twitter @codeout.

Or send a pull request to fix.


## Copyright and License

Copyright (c) 2020 Shintaro Kojima. Code released under the [MIT license](LICENSE.txt).
