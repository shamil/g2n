require 'yaml'

module G2n

  #
  # Yaml config loader class
  # from: http://mjijackson.com/2010/02/flexible-ruby-config-objects
  #
  class Config

    def initialize(data)
      @config = {}
      load!(data.is_a?(Hash) ? data : YAML::load_file(data))
    end

    def load!(data)
      data.each do |key, value|
        self[key] = value
      end
    end

    def [](key)
      @config[key.to_sym]
    end

    def []=(key, value)
      if value.class == Hash
        @config[key.to_sym] = Config.new(value)
      else
        @config[key.to_sym] = value
      end
    end

    def method_missing(sym, *args)
      if sym.to_s =~ /(.+)=$/
        self[$1] = args.first
      else
        self[sym]
      end
    end
  end
end