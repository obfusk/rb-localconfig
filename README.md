[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2014-10-21

    Copyright   : Copyright (C) 2014  Felix C. Stegerman
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

```ruby
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

```bash
rake spec
rake docs
```

## TODO

  * more specs/docs?
  * ...

## License

  LGPLv3+ [1].

## References

  [1] GNU Lesser General Public License, version 3
  --- http://www.gnu.org/licenses/lgpl-3.0.html

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
