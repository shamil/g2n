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

        # print config options in parsable format 'key:value'
        opts.on('--conf <key[,key...]>', 'print config options by key') do |keys|
          self.load_config

          keys.split(',').each do |key|
            unless G2n::GLOBALS.config[key] == nil
              puts "#{key}:" + G2n::GLOBALS.config[key].to_s
            else
              STDERR.puts "ERR: no such config option (#{key})"
            end
          end
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

    def load_config
      G2n::GLOBALS.config = G2n::Config.new(G2n::GLOBALS.conf_dir + '/g2n.yml')
    end

    def run
      self.load_config

      # load hosts from gangla
      hosts = G2n::Ganglia::hosts(G2n::GLOBALS.config.ganglia_host, G2n::GLOBALS.config.ganglia_port)

      # render nagios config per host
      hosts.each do |host|
        nconf = G2n::Renderer.new(host)
        nconf.to_file(G2n::GLOBALS.config.output_path + "/" + host[:hostname] + '.cfg')
      end
    end
  end
end