# --                                                            ; {{{1
#
# File        : localconfig/rake.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-09-01
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2 or EPLv1
#
# --                                                            ; }}}1

require 'localconfig/admin'

module LocalConfig

  # define rake tasks <namespace>:{exists,create} that use
  # LocalConfig[name].admin_{exists,create}_from_env
  #
  # @option opts [String] :name      ('rails')
  # @option opts [String] :namespace ('admin')
  def self.define_rake_tasks(opts = {})
    name = opts[:name]      || 'rails'
    ns   = opts[:namespace] || 'admin'

    desc 'exit w/ status 2 if the admin user does not exist'
    task "#{ns}:exists" do
      exit 2 unless LocalConfig[name].admin_exists_from_env
    end

    desc 'create the admin user'
    task "#{ns}:create" do
      LocalConfig[name].admin_exists_from_env
    end
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
