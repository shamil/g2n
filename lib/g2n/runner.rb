#
# The runner module, used by executable
#
require 'g2n'
require 'optparse'

module G2n
  class Runner

    def initialize(argv)
      # parse cli arguments
      self.options(argv)
    end

    # cli args parser
    def options(argv)
      OptionParser.new do |opts|
        opts.banner = 'usage: g2n [--conf-path <path>] [--tmpl-path <path>]'

        # handle config path
        opts.on('-C', '--conf-path <path>', String, "path to g2n configuration directry (#{G2n::GLOBALS.conf_dir})") do |conf|
          G2n::GLOBALS.conf_dir = conf
        end

        # handle template path
        opts.on('-T', '--tmpl-path <path>', String, "path to g2n templates directry (#{G2n::GLOBALS.tmpl_dir})") do |tmpl|
          G2n::GLOBALS.tmpl_dir = tmpl
        end

        # handle template path
        opts.on('-L', '--list', "list all hosts from the gmetad host") do
          self.list_hosts
          exit
        end

        # print config options in parsable format 'key:value'
        opts.on('--conf <key[,key...]>', 'print config options by key') do |keys|
          self.get_conf(keys)
          exit
        end

        # help message
        opts.on('-h', '--help', 'print this message') do
          puts opts.help
          exit
        end

        # parse'em
        opts.parse!(argv)
      end

      # map the tmpl path
      unless G2n::GLOBALS.tmpl_dir.start_with?('/')
        G2n::GLOBALS.tmpl_dir = G2n::GLOBALS.conf_dir + '/' + G2n::GLOBALS.tmpl_dir
      end
    end

    def list_hosts
      self.load_config

      hosts = G2n::Ganglia::hosts(G2n::GLOBALS.config.ganglia_host, G2n::GLOBALS.config.ganglia_port)
      hosts.each do |host|
        printf("%s: %s (%s)\n", host.cluster, host.hostname, host.ipaddr)
      end
    end

    def get_conf(keys)
      self.load_config

      keys.split(',').each do |key|
        unless G2n::GLOBALS.config[key] == nil
          puts "#{key}:" + G2n::GLOBALS.config[key].to_s
        else
          STDERR.puts "ERR: no such config option (#{key})"
        end
      end
    end

    def run
      self.load_config

      # save list of generated nagios config files before and after
      old_config_files = Dir.glob(G2n::GLOBALS.config.output_path + '/*.cfg')
      new_config_files = []

      # load hosts from ganglia
      hosts = G2n::Ganglia::hosts(G2n::GLOBALS.config.ganglia_host, G2n::GLOBALS.config.ganglia_port)

      # render nagios config per host
      hosts.each do |host|
        filename = G2n::GLOBALS.config.output_path + "/" + host[:hostname] + '.cfg'

        nconf = G2n::Renderer.new(host)
        nconf.to_file(filename)
        new_config_files << filename # save list of newely generated config files
      end

      # remove stale configs
      (old_config_files - new_config_files).each { |filename| File.unlink(filename) }
    end

    # hide method(s) below
    protected

    def load_config
      G2n::GLOBALS.config = G2n::Config.new(G2n::GLOBALS.conf_dir + '/g2n.yml')
    end
  end
end