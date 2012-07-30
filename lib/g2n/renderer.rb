require 'fileutils'
require 'erb'

module G2n
  class Renderer

    # class variables (also called static attributes)
    @@mappings = G2n::Config.new(G2n::GLOBALS.conf_dir + '/mappings.yml')

    # constructor
    def initialize(host)
      # check that we got a right argument type
      unless host.is_a?(Struct::GangliaHost)
        raise ArgumentError, "host must be Struct::GangliaHost (not #{host.class.to_s})."
      end

      # set instance variables for the host
      @cluster  = @@mappings[host.cluster].is_a?(G2n::Config) ? host.cluster : 'default' # assign default mapping if needed
      @hostname = host.hostname
      @ipaddr   = host.ipaddr
      @desc     = @@mappings[@cluster].desc
    end

    def to_file(path)
      FileUtils.mkpath(File.dirname(path))
      File.open(path, 'w') {|file| file.write self.render }
    end

    def to_s
      return self.render
    end

    # hide method(s) below
    protected

    def render
      template_file = G2n::GLOBALS.tmpl_dir + "/" + @@mappings[@cluster].template + ".erb"

      begin
        erb = ERB.new(File.read(template_file))
      rescue Errno::ENOENT
        if @cluster == "default"
          abort "Aborting, no default template was found."
        else
          STDERR.puts "Skipping '#{@cluster}', no template was found."
          return
        end
      end

      # return the generated nagios conf
      return erb.result(binding)
    end
  end
end