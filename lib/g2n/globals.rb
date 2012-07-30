require 'singleton'

#
# g2n globals singleton
#
module G2n
  class Globals
    include Singleton
    attr_accessor :conf_dir, :tmpl_dir
  end

  GLOBALS = G2n::Globals.instance
end