#
# The runner module, used by executable
#
require 'g2n'

module G2n
  class Runner
    def initialize(argv)
      @config = Config.new("#{CONFIG_DIR}/g2n.yml")
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