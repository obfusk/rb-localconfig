# --                                                            ; {{{1
#
# File        : localconfig/rake.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-08-30
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2 or EPLv1
#
# --                                                            ; }}}1

require 'localconfig/admin'

module LocalConfig
  def self.define_rake_tasks(namespace: 'admin')
    desc 'returns 0 if the admin user exists, 2 if it does not'
    task "#{namespace}:exists" do
      exit 2 unless LocalConfig::Admin.admin_exists?
    end
    desc 'create the admin user'
    task "#{namespace}:create" do
      LocalConfig::Admin.create_admin_from_env
    end
  end
end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
