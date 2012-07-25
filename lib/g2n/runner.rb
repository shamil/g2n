require_relative 'config'

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