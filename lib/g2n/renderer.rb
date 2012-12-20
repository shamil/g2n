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

    def to_s
      return self.render unless self.check_bypass
    end

    def to_file(path)
      FileUtils.mkpath(File.dirname(path))
      File.open(path, 'w') {|file| file.write self.to_s }
    end

    # hide method(s) below
    protected

    def check_bypass
      filters = @@mappings[@cluster].bypass

      # only string and array are allowed
      unless (filters.is_a?(String) || filters.is_a?(Array))
          STDERR.puts "Skipping bypass filter for '#{@cluster}', the filter is in wrong format." unless filters.nil?
          return false
      end

      # if it's string, then make it an array
      filters = [filters] unless filters.is_a?(Array)
      filters.each do |bypass|
        if (File.fnmatch(bypass, @hostname) || File.fnmatch(bypass, @ipaddr))
          STDERR.puts "Skipping config for '#{@hostname} (#{@ipaddr})', bypass filter matched (#{filters.join(',')})."
          return true
        end
      end
      return false
    end

    def render
      template = @@mappings[@cluster].template || @cluster
      template_file = G2n::GLOBALS.tmpl_dir + "/" + template + ".erb"

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