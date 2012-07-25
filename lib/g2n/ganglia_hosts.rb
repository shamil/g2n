require "rexml/document"
require 'socket'

module G2n
  module Ganglia
    def self.hosts(host, port)

      # Open up a socket to gmond
      #file = TCPSocket.open(host, port)
      file = File.open('/tmp/ganglia.xml')

      # Parse the XML we got from gmond
      doc = REXML::Document.new file

      # Disconnect
      file.close()

      hosts = []
      doc.elements.each("/GANGLIA_XML/GRID/CLUSTER") { |element|
        cluster = element.attributes["NAME"]

        doc.elements.each("/GANGLIA_XML/GRID/CLUSTER[@NAME='#{cluster}']/HOST") { |host|
          hosts << {
            :cluster  => cluster,
            :ipaddr   => host.attributes['IP'],
            :hostname => host.attributes['NAME'],
          }
        }
      }

      return hosts
    end
  end
end