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

To verify configurations syntax:

```zsh
$ junoser -c config.txt
```

or

```zsh
$ cat config.txt | junoser -c
```

To translate configuration into "display set" form:

```zsh
$ /exe/junoser -d config.txt
set protocols bgp group ebgp-peers neighbor 192.0.2.2
```

or

```zsh
$ cat config.txt | junoser -d
set protocols bgp group ebgp-peers neighbor 192.0.2.2
```

Use ```junoser -s``` to translate into structured form.


## Contributing

Please report issues or enhancement requests to [GitHub issues](https://github.com/codeout/junoser/issues).
For questions or feedbacks write to my twitter @codeout.

Or send a pull request to fix.


## Copyright and License

Copyright (c) 2015 Shintaro Kojima. Code released under the [MIT license](LICENSE.txt).
