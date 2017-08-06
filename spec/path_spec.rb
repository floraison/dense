
#
# Specifying fugit
#
# Sun Aug  6 08:04:41 JST 2017
#

require 'spec_helper'


describe Dense::Path do

  describe '.new' do

    it 'parses a path string' do

      pa = Dense::Path.new('0.name')

      expect(pa.to_a).to eq([ 0, 'name' ])
    end
  end
end

