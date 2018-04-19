
#
# Specifying dense
#
# Sun Aug  6 07:22:20 JST 2017
#

require 'pp'
require 'json'

require 'dense'


class Object
  def to_pp
    PP.pp(self, StringIO.new).string
  end
end

