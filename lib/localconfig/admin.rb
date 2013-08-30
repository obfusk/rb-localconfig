# --                                                            ; {{{1
#
# File        : localconfig/admin.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-08-30
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2 or EPLv1
#
# --                                                            ; }}}1

module LocalConfig
  class Admin
    def exists?
    end

    def create(username, password, email)
    end

    def create_from_env
      create ENV['USERNAME'], ENV['PASSWORD'],
        ENV['EMAIL']
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
