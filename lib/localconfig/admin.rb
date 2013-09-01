# --                                                            ; {{{1
#
# File        : localconfig/admin.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-09-01
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2 or EPLv1
#
# --                                                            ; }}}1

require 'localconfig/config'

# namespace
module LocalConfig

  class Config                                                  # {{{1

    # set to true to disable rake tasks in railtie
    attr_accessor :no_rake

    # block will be run on admin_exists
    def on_admin_exists(&b)
      @admin_exists = b
    end

    # block will be run on admin_create
    def on_admin_create(&b)
      @admin_create = b
    end

    # run block set w/ on_admin_exists
    def admin_exists(username)
      @admin_exists[username]
    end

    # run block set w/ on_admin_create
    def admin_create(username, password, email)
      @admin_create[username, password, email]
    end

    # run admin_exists w/ $USERNAME
    def admin_exists_from_env
      admin_exists ENV['USERNAME']
    end

    # run admin_create w/ $USERNAME, $PASSWORD, $EMAIL
    def admin_create_from_env
      admin_create ENV['USERNAME'], ENV['PASSWORD'], ENV['EMAIL']
    end

  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
