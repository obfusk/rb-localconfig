# --                                                            ; {{{1
#
# File        : localconfig/config.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-09-01
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2 or EPLv1
#
# --                                                            ; }}}1

require 'hashie/mash'
require 'json'
require 'yaml'

module LocalConfig

  CONFIGS = {}

  # --

  # configuration
  class Config                                                  # {{{1

    # dir
    attr_accessor :dir

    # name
    attr_accessor :name

    # set dir to ~/.apps, derive name
    def initialize(opts = {})
      @config = {}
      @dir    = opts[:dir] || "#{Dir.home}/.apps"
      @name   = opts[:name] || derive_name
    end

    # configure; self is passed to the block
    # @return self
    def configure(&b)
      b[self]; self
    end

    # derive name
    # @option opts [String]   :dir  (Dir.pwd)
    # @option opts [<String>] :up   (%w{ app })
    # @option opts [String]   :env  (ENV['LOCALCONFIG_NAME'])
    # @return [String] env (if not empty) or basename of dir; if
    #                  basename of dir in up, uses one dir up
    def derive_name(opts = {})                                  # {{{2
      dir = opts[:dir] || Dir.pwd; up = opts[:up] || %w{ app }
      env = opts.fetch(:env) { ENV['LOCALCONFIG_NAME'] }
      if env && !env.empty?
        env
      else
        d, b = File.split dir; up.include?(b) ? File.basename(d) : b
      end
    end                                                         # }}}2

    # `<dir>/<name>/...`
    def path(*paths)
      ([dir,name] + paths)*'/'
    end

    # glob in path
    def glob(*args, &b)
      Dir.chdir(path) { Dir.glob(*args, &b) }
    end

    # require relative to path
    def require(*files)
      _files(files).map { |f| Kernel.require f }
    end

    # load json file relative to path and store as Hashie::Mash in
    # self.<basename>
    def load_json(*files)
      _load '.json', (-> x { JSON.parse x }), files
    end

    # load yaml file relative to path and store as Hashie::Mash in
    # self.<basename>
    def load_yaml(*files)
      _load '.yaml', (-> x { YAML.load x }), files
    end

    # --

    # files relative to path
    def _files(files)
      files.map { |f| "#{path}/#{f}" }
    end

    # load file relative to path and store as Hashie::Mash in
    # self.<basename>
    def _load(ext, parse, files)                                # {{{2
      _files(files).each do |f|
        b = File.basename f, ext
        raise "@config[#{b}] already defined" if @config[b]
        @config[b] = Hashie::Mash.new parse[File.read(f)]
        define_singleton_method(b) { @config[b] }
      end
    end                                                         # }}}2

  end                                                           # }}}1

  # --

  # get (new) Config by name
  def self.[](name)
    CONFIGS[name] ||= Config.new
  end

  # like Rails.env
  def self.env
    @env ||= ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
