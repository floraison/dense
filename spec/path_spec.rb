
#
# Specifying dense
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
      "name.first"     => [ 'name', 'first' ],
      "name['first']"  => [ 'name', 'first' ],
      'name["last"]'   => [ 'name', 'last' ],
      'name[0]'        => [ 'name', 0 ],
      '[0].name'       => [ 0, 'name' ],

      '.name'        => [ '.', 'name' ],
      '.["name"]'    => [ '.', 'name' ],
      'store..name'  => [ 'store', '.', 'name' ],

      'name[*]'    => [ 'name', '*' ],
      'name[::1]'  => [ 'name', { start: nil, end: nil, step: 1 } ],

      'name.*' => [ 'name', '*' ],

      '[\'name\',"age"]'   => [ [ 'name', 'age' ] ],
      'x[\'name\',"age"]'  => [ 'x', [ 'name', 'age' ] ],

      '11.name'      => [ 11, 'name' ],
      '11["name"]'   => [ 11, 'name' ],
      '11["name",]'  => [ 11, [ 'name' ] ],
      '11[0,]'       => [ 11, [ 0 ] ],

      '[1:2,10:20,99]' => [
        [ { start: 1, end: 2, step: nil },
          { start: 10, end: 20, step: nil },
          99 ] ],


    }.each do |s, a|

      it "parses #{s.inspect}" do
      #it "parses #{s.inspect} to #{a.inspect}" do

        expect(Dense::Path.new(s).to_a).to eq(a)
      end
    end
  end
end

