require_relative 'config'
require_relative 'ganglia_hosts'


module G2n
  class Runner
    def initialize(argv)
      @config = Config.new('config/g2n.yml')
      @mappings = Config.new('config/mappings.yml')
    end

    def run
    end
  end
end