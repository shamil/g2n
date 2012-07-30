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

      @config = G2n::Config.new(G2n::GLOBALS.conf_dir + '/g2n.yml')
      @hosts  = G2n::Ganglia::hosts(@config.ganglia_host, @config.ganglia_port)
    end

    # cli args parser
    def options(argv)
      OptionParser.new do |opts|
        opts.banner = 'usage: g2n [options]'

        opts.on('-C', '--conf-path <path>', String, "path to g2n configuration directry (#{G2n::GLOBALS.conf_dir})") do |conf|
          G2n::GLOBALS.conf_dir = conf
        end

        opts.on('-T', '--tmpl-path <path>', String, "path to g2n templates directry (#{G2n::GLOBALS.tmpl_dir})") do |tmpl|
          G2n::GLOBALS.tmpl_dir = tmpl
        end

        opts.on('-h', '--help', 'print this message') do
          puts opts
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

    def run
      # render nagios config per host
      @hosts.each do |host|
        nconf = G2n::Renderer.new(host)
        nconf.to_file(@config.output_path + "/" + host[:hostname] + '.cfg')
      end
    end
  end
end