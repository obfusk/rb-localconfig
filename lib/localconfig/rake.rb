# --                                                            ; {{{1
#
# File        : localconfig/rake.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-10-21
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'rake/dsl_definition'

require 'localconfig/admin'

# namespace
module LocalConfig

  # rake tasks
  module Rake
    extend ::Rake::DSL

    # define rake tasks `<namespace>:{exists,create}` that use
    # `LocalConfig[name].admin_{exists,create}_from_env`
    #
    # @option opts [String] :name      ('rails')
    # @option opts [String] :namespace ('admin')
    def self.define_tasks(opts = {})
      name = opts[:name]      || 'rails'
      ns   = opts[:namespace] || 'admin'

      desc 'exit w/ status 2 if the admin user does not exist'
      task "#{ns}:exists" => :environment do
        exit 2 unless LocalConfig[name].admin_exists_from_env
      end

      desc 'create the admin user'
      task "#{ns}:create" => :environment do
        LocalConfig[name].admin_create_from_env
      end
    end

  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
