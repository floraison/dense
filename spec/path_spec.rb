
#
# Specifying fugit
#
# Sun Aug  6 08:04:41 JST 2017
#

require 'spec_helper'


describe Dense::Path do

  describe '.new' do

    {

      '0.name'         => [ 0, 'name' ],
      'name.0'         => [ 'name', 0 ],
      '11[0]'          => [ 11, 0 ],
      "name['first']"  => [ 'name', 'first' ],
      'name["last"]'   => [ 'name', 'last' ],
      'name[0]'        => [ 'name', 0 ],
      '[0].name'       => [ 0, 'name' ],

      '..name'         => [ '..', 'name' ],

      'name[*]'        => [ 'name', '*' ],
      'name[::1]'      => [ 'name', { start: nil, end: nil, step: 1 } ],

    }.each do |s, a|

      it "parses #{s.inspect}" do
      #it "parses #{s.inspect} to #{a.inspect}" do

        expect(Dense::Path.new(s).to_a).to eq(a)
      end
    end
  end
end

