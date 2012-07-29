require 'socket'
require 'timeout'
require "rexml/document"

module G2n
  module Ganglia

    def self.hosts(host, port)
      # open file directly if starts with file://
      if host.downcase.start_with?('file://')
          filename = host.downcase.sub('file://', '')
          file = File.open(filename)
      else
        begin
          file = TCPSocket.open(host, port)
        rescue Exception => e
          Kernel.abort "#{e.class.to_s}: #{e.message}, (#{host}:#{port})"
        end
      end

      # Parse the XML we got from gmond
      doc = Timeout::timeout(10) { REXML::Document.new file }

      # Disconnect
      file.close()

      hosts = []
      Struct.new("GangliaHost", :cluster, :ipaddr, :hostname)

      doc.elements.each("/GANGLIA_XML/GRID/CLUSTER") do |element|
        cluster = element.attributes["NAME"]

        doc.elements.each("/GANGLIA_XML/GRID/CLUSTER[@NAME='#{cluster}']/HOST") do |host|
          hosts << Struct::GangliaHost.new(cluster, host.attributes['IP'], host.attributes['NAME'])
        end
      end

      return hosts
    end
  end
end