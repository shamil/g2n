require_relative 'config'
require_relative 'renderer'
require_relative 'ganglia_hosts'

module G2n
  class Runner
    def initialize(argv)
      @config = Config.new('config/g2n.yml')
      @hosts  = Ganglia::hosts(@config.ganglia_host, @config.ganglia_port)
    end

    def run
      # render nagios config per host
      @hosts.each do |host|
        nconf = G2n::Renderer.new(host)
        nconf.output(@config.output_path + "/" + host[:hostname] + '.cfg')
      end
    end
  end
end