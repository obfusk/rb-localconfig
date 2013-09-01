[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2013-09-01

    Copyright   : Copyright (C) 2013  Felix C. Stegerman
    Version     : v0.2.1.SNAPSHOT

[]: }}}1

[![Gem Version](https://badge.fury.io/rb/localconfig.png)](http://badge.fury.io/rb/localconfig)

## Description
[]: {{{1

  [rb-]localconfig - local configuration for ruby (web) apps

  localconfig makes it easy to load (additional) configuration files
  from `~/.apps/<name>`, where name is determined by the current
  directory.  You can easily require ruby files and load json and yaml
  files from this directory.

  Additionally, it allows rails applications to easily define
  admin:exists and admin:create rake tasks to make it easier to
  automate application setup.

  Just about everything is configurable: see the docs.

  For an example w/ rails, see
  https://github.com/obfusk/localconfig-rails-example.

[]: }}}1

## Examples
[]: {{{1

Gemfile

```
gem 'localconfig', require: 'localconfig/rails'
```

config/localconfig.rb

```ruby
LocalConfig['rails'].configure do |c|
  puts "env: #{c.env}, #{Rails.env}"
  c.require 'init.rb'
  c.load_json 'pg.json'
  c.on_admin_exists do |username|
    # ...
  end
  c.on_admin_create do |username, password, email|
    # ...
  end
end
```

[]: }}}1

## Specs & Docs
[]: {{{1

    $ rake spec
    $ rake docs

[]: }}}1

## TODO
[]: {{{1

  * more specs/docs?
  * ...

[]: }}}1

## License
[]: {{{1

  GPLv2 [1] or EPLv1 [2].

[]: }}}1

## References
[]: {{{1

  [1] GNU General Public License, version 2
  --- http://www.opensource.org/licenses/GPL-2.0

  [2] Eclipse Public License, version 1
  --- http://www.opensource.org/licenses/EPL-1.0

[]: }}}1

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
