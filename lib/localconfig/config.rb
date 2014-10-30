# --                                                            ; {{{1
#
# File        : localconfig/config.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-10-30
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'hashie/mash'
require 'json'
require 'pathname'
require 'yaml'

# namespace
module LocalConfig

  CONFIGS = {}

  # --

  # configuration
  class Config                                                  # {{{1

    class Error < StandardError; end

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

    # access setting by key
    def [](k)
      @config[k.to_s]
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

    # `dir/name/...`
    def path(*paths)
      ([dir,name] + paths)*'/'
    end

    # glob in path
    def glob(*args, &b)
      Dir.chdir(path) { Dir.glob(*args, &b) }
    end

    # require relative to path
    def require(*files)
      _files(files).each { |f| Kernel.require f[:path] }
      nil
    end

    # load json file relative to path and store as Hashie::Mash in
    # self; for example:
    #
    # ```
    # lc.load_json 'foo.json'
    # lc.foo.key1
    # lc.load_json 'bar/baz.json'
    # lc.bar.baz.key2
    # ```
    def load_json(*files)
      _load %w{ .json }, (-> x { JSON.parse x }), files
    end

    # load yaml file relative to path and store as Hashie::Mash in
    # self; for example:
    #
    # ```
    # lc.load_yaml 'foo.yaml'
    # lc.foo.key1
    # lc.load_yaml 'bar/baz.yml'
    # lc.bar.baz.key2
    # ```
    def load_yaml(*files)
      _load %w{ .yml .yaml }, (-> x { YAML.load x }), files
    end

    # `load_{json,yaml}` `*.json`, `*.y{a,}ml` in dir; for example:
    #
    # ```
    # lc.load_dir 'more'  # more/foo.json, more/bar.yml
    # lc.more.foo.key1
    # lc.more.bar.key2
    # ```
    def load_dir(*dirs)
      dirs.flat_map do |d|
        j = glob "#{d}/*.json"; y = glob "#{d}/*.y{a,}ml"
        load_json *j; load_yaml *y; j + y
      end
    end

    # <!-- {{{2 -->
    #
    # clone/fetch git repo in dir (to load more config files from
    # elsewhere); for example:
    #
    # ```
    # lc.load_yaml 'git.yml'  # repo:, branch:
    # lc.git_repo 'more', c.git.repo, branch: c.git.branch
    # lc.load_dir 'more'      # more/foo.yml, more/bar.json
    # ```
    #
    # You can't use more than one of `:rev`, `:tag`, `:branch`; if you
    # specify none, the default is `branch: 'master'`.
    #
    # @param [String] path  subpath to clone to
    # @param [String] url   url to clone from
    #
    # @param [Hash] opts options
    # @option opts [Bool]   :quiet  (true)  whether to be quiet
    # @option opts [String] :rev            specific revision (SHA1)
    # @option opts [String] :tag            specific tag
    # @option opts [String] :branch         specific branch
    #
    # <!-- }}}2 -->
    def git_repo(path, url, opts = {})                          # {{{2
      %w{ branch rev tag }.count { |x| opts.has_key? x.to_sym } <= 1 \
        or raise ArgumentError,
          "You can't use more than one of :rev, :tag, :branch"
      q       = opts.fetch(:quiet, true) ? %w{ --quiet } : []
      s       = opts.fetch(:quiet, true) ?
                  -> *a {                    _sys *a } :
                  -> *a { puts "$ #{a*' '}"; _sys *a }
      b       = opts[:branch]; b = "origin/#{b}" if b && !b['/']
      rev     = opts[:rev] || opts[:tag]
      ref     = rev || b || 'origin/master'
      dest    = path path
      if File.exist? dest
        Dir.chdir(dest) do
          _git_dir_check
          s[*(%w{ git fetch --force --tags } + q)] \
            unless rev && %x[ git rev-parse HEAD ] ==
                          %x[ git rev-parse --revs-only #{rev}^0 -- ]
        end
      else
        s[*(%w{ git clone } + q + [url, dest])]
      end
      Dir.chdir(dest) do
        _git_dir_check
        s[*(%w{ git reset --hard } + q + [ref] + %w{ -- })]
      end
    end                                                         # }}}2

    # --

    # LocalConfig.branch
    def branch; LocalConfig.branch; end

    # LocalConfig.env
    def env; LocalConfig.env; end

    # --

    # files relative to path
    def _files(files)
      files.map { |f| { f: f, path: "#{path}/#{f}" } }
    end

    # load file relative to path and store as Hashie::Mash in self
    def _load(exts, parse, files)                               # {{{2
      _files(files).each do |f|
        *pre, b = all = Pathname.new(f[:f]).each_filename.to_a
        ext     = exts.find { |x| b.end_with? x } || ''
        k       = File.basename b, ext  ; c_k = (pre+[k]).first
        o       = @config
        pre.each { |x| o[x] ||= Hashie::Mash.new; o = o[x] }
        raise "self.#{(pre+[k])*'.'} already set" if o[k]
        o[k]    = Hashie::Mash.new parse[File.read(f[:path])]
        define_singleton_method(c_k) { @config[c_k] } \
          unless self.respond_to? c_k
      end
      nil
    end                                                         # }}}2

    # check for .git/
    def _git_dir_check
      File.exist? '.git/' or raise Error, 'not a git dir'
    end

    # run!
    def _sys(cmd, *args)
      system([cmd, cmd], *args) or \
        raise Error, "failed to run command #{[cmd]+args} (#$?)"
    end

  end                                                           # }}}1

  # --

  # get (new) Config by name
  def self.[](name)
    CONFIGS[name] ||= Config.new
  end

  # either the current git branch, '(HEAD)' for a detached head, or
  # nil if not in a git repo; (cached);
  #
  # to use this in a Gemfile, you will need to have the localconfig
  # gem installed locally before running bundle
  def self.branch
    @branch ||= _branch
  end

  # like Rails.env; (cached)
  def self.env
    @env ||= ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
  end

  # --

  # current git branch
  def self._branch
    c = 'git symbolic-ref -q HEAD 2>/dev/null'
    b = %x[#{c}].chomp.sub %r{^refs/heads/}, ''
    [0,1].include?($?.exitstatus) ? (b.empty? ? '(HEAD)' : b) : nil
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
