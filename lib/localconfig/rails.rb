# --                                                            ; {{{1
#
# File        : localconfig/rails.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-09-01
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2 or EPLv1
#
# --                                                            ; }}}1

require 'rails'

require 'localconfig'

module LocalConfig
  class Railtie < Rails::Railtie
    config.local = LocalConfig['rails']
    rake_tasks { LocalConfig.define_rake_tasks } \
      unless LocalConfig['rails'].no_rake
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
