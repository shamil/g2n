require 'g2n/globals'

#
# g2n globals
#
module G2n
  # set defaults
  GLOBALS.conf_dir = 'config'    # FIXME: put back '/etc/g2n'
  GLOBALS.tmpl_dir = 'templates' # relative to 'conf_dir' (forward slash omitted)
end

#
# g2n requires
#
require 'g2n/config'
require 'g2n/renderer'
require 'g2n/ganglia_hosts'
