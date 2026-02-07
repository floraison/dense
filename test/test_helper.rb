
#
# Testing dense
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

# Black       0;30     Dark Gray     1;30
# Blue        0;34     Light Blue    1;34
# Green       0;32     Light Green   1;32
# Cyan        0;36     Light Cyan    1;36
# Red         0;31     Light Red     1;31
# Purple      0;35     Light Purple  1;35
# Brown       0;33     Yellow        1;33
# Light Gray  0;37     White         1;37

RS = "[0;0m"
  #
RD = "[0;31m"
LR = "[1;31m"
DG = "[1;30m"
GN = "[0;32m"
LN = "[1;32m"
YL = "[1;33m"
BL = "[0;34m"
LB = "[1;34m"
LG = "[0;37m"

