require 'fileutils'
require 'erb'

module G2n
  class Renderer

    # class variables (also called static attributes)
    @@mappings = Config.new("#{CONFIG_DIR}/mappings.yml")

    # constructor
    def initialize(ganglia_host)
      if ganglia_host.is_a?(Hash)
        @host = ganglia_host
      else
        raise TypeError, "'ganglia_host' is not Hash."
      end

      # set instance variables for the host
      @cluster  = @@mappings[@host[:cluster]].is_a?(G2n::Config) ? @host[:cluster] : 'default' # assign default mapping if needed
      @hostname = @host[:hostname]
      @ipaddr   = @host[:ipaddr]
      @desc     = @@mappings[@cluster].desc
    end

    def output(path)
      FileUtils.mkpath(File.dirname(path))
      File.open(path, 'w') {|file| file.write self.render }
    end

    # hide methd(s) below
    protected

    def render
      template_file = TEMPLATES_DIR + "/" + @@mappings[@cluster].template + ".erb"

      begin
        erb = ERB.new(File.read(template_file))
      rescue Errno::ENOENT
        if @cluster == "default"
          Kernel.abort "Aborting, no default template was found."
        else
          $stderr.puts "Skipping, no #{@cluster} template was found."
        end
      end

      # return the generated nagios conf
      return erb.result(binding)
    end
  end
end