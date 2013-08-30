# --                                                            ; {{{1
#
# File        : localconfig/rails.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-08-30
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2 or EPLv1
#
# --                                                            ; }}}1

require 'localconfig'
require 'localconfig/rake'

require 'rails'

module LocalConfig
  class Railtie < Rails::Railtie
    rake_tasks do
      LocalConfig.define_rake_tasks
    end

    def self.
      config.localconfig = # ...
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
