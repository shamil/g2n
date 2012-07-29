

module G2n
  #
  # constants
  #
  CONFIG_DIR = 'config' # '/etc/g2n'
  TEMPLATES_DIR = "#{CONFIG_DIR}/templates"
end

#
# g2n requires
#
require 'g2n/config'
require 'g2n/renderer'
require 'g2n/ganglia_hosts'
