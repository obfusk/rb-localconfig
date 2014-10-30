# --                                                            ; {{{1
#
# File        : localconfig/config_spec.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-10-30
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'localconfig/config'

require 'fileutils'
require 'tmpdir'

lcc = LocalConfig::Config

gist1 = 'https://gist.github.com/009eae662748f8778bed.git'
gist2 = 'https://gist.github.com/80edcd5455d348f9ccb7.git'

describe lcc do

  apps  = "#{Dir.pwd}/test/apps"
  d1    = "#{apps}/test1"
  d2    = "#{apps}/test2"
  d3    = "#{apps}/test3"
  test1 = Dir.chdir('test/test1')     { lcc.new dir: apps }
  test2 = Dir.chdir('test/test2/app') { lcc.new dir: apps }
  test3 = Dir.chdir('test/test1') do
    old = ENV['LOCALCONFIG_NAME']; ENV['LOCALCONFIG_NAME'] = 'test3'
    x = lcc.new dir: apps; ENV['LOCALCONFIG_NAME'] = old; x
  end

  context 'dir, name, path' do                                  # {{{1
    it 'test1 is OK' do
      expect(test1.dir).to eq apps
      expect(test1.name).to eq 'test1'
      expect(test1.path).to eq d1
    end
    it 'test2 is OK' do
      expect(test2.dir).to eq apps
      expect(test2.name).to eq 'test2'
      expect(test2.path).to eq d2
    end
    it 'test3 is OK' do
      expect(test3.dir).to eq apps
      expect(test3.name).to eq 'test3'
      expect(test3.path).to eq d3
    end
  end                                                           # }}}1

  context 'configure' do                                        # {{{1
    it 'is passed self and returns self' do
      x = nil
      y = test1.configure { |c| x = c }
      expect(x).to be test1
      expect(y).to be test1
    end
  end                                                           # }}}1

  context 'path' do                                             # {{{1
    it 'joins' do
      expect(test1.path 'foo', 'bar').to eq "#{d1}/foo/bar"
    end
  end                                                           # }}}1

  context 'glob' do                                             # {{{1
    it '* -> bar foo init.rb pg.json' do
      expect(test1.glob('*').sort).to eq \
        %w{ bar foo init.rb pg.json }
    end
    it '*.json -> pg.json' do
      expect(test1.glob('*.json').sort).to eq %w{ pg.json }
    end
  end                                                           # }}}1

  context 'require' do                                          # {{{1
    it 'requires init.rb' do
      old = $stdout; $stdout = out = StringIO.open('', 'w')
      begin test1.require 'init.rb' rescue $stdout = old end
      expect(out.string).to eq "init!\n"
    end
  end                                                           # }}}1

  context 'load_json' do                                        # {{{1
    it 'loads pg.json' do
      x = test1.dup; x.load_json 'pg.json'
      expect(x.pg.to_hash).to eq \
        ({ 'database' => 'foo', 'username' => 'foo',
           'password' => 'bar' })
    end
  end                                                           # }}}1

  context 'load_yaml' do                                        # {{{1
    it 'loads foo/x.yaml' do
      x = test1.dup; x.load_yaml 'foo/x.yaml'
      expect(x[:foo].x.to_hash).to eq({ 'foo' => 99, 'bar' => 'hi!' })
    end
  end                                                           # }}}1

  context 'load_dir' do                                         # {{{1
    it 'loads bar/y.yml' do
      x = test1.dup; x.load_dir 'bar'
      expect(x.bar.y.to_hash).to \
        eq({ 'spam' => true, 'eggs' => false })
    end
  end                                                           # }}}1

  context 'git_repo' do                                         # {{{1
    before(:all) do
      @pwd = Dir.pwd; @dir = Dir.mktmpdir
      FileUtils.mkdir_p "#{@dir}/foo"
      FileUtils.mkdir_p "#{@dir}/apps/foo"
      FileUtils.mkdir_p "#{@dir}/apps/foo/not_a_git_dir"
      Dir.chdir "#{@dir}/foo"
    end

    before(:each) do
      @lc = lcc.new dir: "#{@dir}/apps"
    end

    after(:all) do
      Dir.chdir @pwd; FileUtils.remove_entry_secure @dir
    end

    it 'clones (& .branch is OK)' do
      @lc.git_repo 'lc_gist', gist1
      @lc.load_dir 'lc_gist'
      expect(@lc.lc_gist.foo.to_hash) .to \
        eq({ 'x' => 42, 'y' => 37 })
      expect(@lc.lc_gist.bar.to_hash) .to \
        eq({ 'spam' => true, 'eggs' => false })
      expect(@lc.lc_gist.baz.to_hash) .to \
        eq({ 'answer' => 42 })
      Dir.chdir("#{@dir}/apps/foo/lc_gist") do
        expect(LocalConfig.branch).to eq('master')
      end
    end
    it 'resets' do
      @lc.git_repo 'lc_gist', gist1, rev: 'ba232fd'
      @lc.load_dir 'lc_gist'
      expect(@lc.lc_gist.foo.to_hash) .to \
        eq({ 'x' => 42, 'y' => 99 })
    end
    it 'fetches' do
      Dir.chdir("#{@dir}/apps/foo/lc_gist") do
        system *(%w{ git remote set-url origin } + [gist2]) \
          or raise 'OOPS'
      end
      @lc.git_repo 'lc_gist', gist2, tag: 'tag_2'
      @lc.load_dir 'lc_gist'
      expect(@lc.lc_gist.foo.to_hash) .to \
        eq({ 'x' => 42, 'y' => 37, 'z' => true })
    end
    it 'complains w/ tag + branch' do
      expect { @lc.git_repo 'dummy', gist1, tag: 'foo', branch: 'bar' } \
        .to raise_error(ArgumentError,
          "You can't use more than one of :rev, :tag, :branch")
    end
    it 'complains w/o .git' do
      expect { @lc.git_repo 'not_a_git_dir', gist1 } \
        .to raise_error(lcc::Error, 'not a git dir')
    end
  end                                                           # }}}1

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
