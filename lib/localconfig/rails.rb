# --                                                            ; {{{1
#
# File        : localconfig/rails.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-10-21
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'rails'

require 'localconfig'

# namespace
module LocalConfig

  # railtie that sets config.local to LocalConfig['rails'] and adds
  # the rake tasks
  class Railtie < Rails::Railtie
    config.local = LocalConfig['rails']
    rake_tasks { LocalConfig::Rake.define_tasks } \
      unless LocalConfig['rails'].no_rake
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
