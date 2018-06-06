
#
# Specifying dense
#
# Sun Aug  6 08:04:41 JST 2017
#

require 'spec_helper'


describe Dense::Path do

  describe '.new' do

    it "fails if the input path is not a String" do

      expect {
        Dense::Path.new(1)
      }.to raise_error(
        ArgumentError, /\Aargument is a (Integer|Fixnum), not a String\z/
      )
        # >= 2.4 Integer
    end

    {

      '0'              => [ 0 ],
      'name'           => [ 'name' ],
      '0.name'         => [ 0, 'name' ],
      'name.0'         => [ 'name', 0 ],
      '11[0]'          => [ 11, 0 ],
      "name.first"     => [ 'name', 'first' ],
      "name['first']"  => [ 'name', 'first' ],
      'name["last"]'   => [ 'name', 'last' ],
      'name[0]'        => [ 'name', 0 ],
      '[0].name'       => [ 0, 'name' ],

      '.name'        => [ :dot, 'name' ],
      '.["name"]'    => [ :dot, 'name' ],
      'store..name'  => [ 'store', :dot, 'name' ],

      'name.*'         => [ 'name', :star ],
      'name[*]'        => [ 'name', :star ],
      'name[::1]'      => [ 'name', { start: nil, end: nil, step: 1 } ],
      'book[*].title'  => [ 'book', :star, 'title' ],
      'name.[*]'       => [ 'name', :dotstar ],
      'name..*'        => [ 'name', :dotstar ],

      '.*' => [ :dotstar ],
      '[*]' => [ :star ],
      '.[*]' => [ :dotstar ],

      'x..y...z' => [ 'x', :dot, 'y', :dot, 'z' ],

      'name..[*]' => [ 'name', :dotstar ],
      'name...something' => [ 'name', :dot, 'something' ],

      '[\'name\',"age"]'   => [ [ 'name', 'age' ] ],
      'x[\'name\',"age"]'  => [ 'x', [ 'name', 'age' ] ],

      '11.name'       => [ 11, 'name' ],
      '11["name"]'    => [ 11, 'name' ],
      '11[age]'       => [ 11, 'age' ],
      '11[name,age]'  => [ 11, [ 'name', 'age' ] ],
      '11["name",]'   => [ 11, [ 'name' ] ],
      '11[0,]'        => [ 11, [ 0 ] ],

      '[1:2,10:20,99]' => [
        [ { start: 1, end: 2, step: nil },
          { start: 10, end: 20, step: nil },
          99 ] ],

      'x["name\'+-.nada"]' => [ 'x', 'name\'+-.nada' ],
      "x['name\"+-.nada']" => [ 'x', 'name"+-.nada' ],

      '+' => [ '+' ],
      '-' => [ '-' ],
      '/' => [ '/' ],
      '%' => [ '%' ],
      '>' => [ '>' ],
      '<' => [ '<' ],
      '=' => [ '=' ],
      '?' => [ '?' ],

      '*' => [ :star ],
      '\*' => [ '*' ],
      '\.' => [ '.' ],

      '*.0' => [ :star, 0 ],
      '*[0]' => [ :star, 0 ],
      '.*.0' => [ :dotstar, 0 ],
      '.*[0]' => [ :dotstar, 0 ],

      'aAbZ/\0-9^' => [ 'aAbZ/\0-9^' ],

      'x./(id|name)/' => [ 'x', /(id|name)/ ],
      'x[/(id|name)/,y]' => [ 'x', [ /(id|name)/, 'y' ] ],
      #'x./(id|name)/xn' => [ 'x', /(id|name)/x ], # no worky, diff-lcs?
      'x./(id|name)/x' => [ 'x', /(id|name)/x ],

    }.each do |s, a|

      it "parses #{s.inspect}" do
      #it "parses #{s.inspect} to #{a.inspect}" do

        expect(Dense::Path.new(s).to_a).to eq(a)
      end
    end
  end

  describe '#[]' do

    context '(int)' do

      it 'returns a key' do

        expect(Dense::Path.new('a.b.c.d')[1]).to eq('b')
      end

      it 'returns a key' do

        expect(Dense::Path.new('a["b","B"].c.d')[1]).to eq(%w[ b B ])
      end
    end

    context '(int..int)' do

      it 'returns a Path instance' do

        expect(
          Dense::Path.new('a.b.c.d')[1..2]
        ).to eq(
          Dense::Path.new('b.c')
        )
      end
    end

    context '(int, int)' do

      it 'returns a Path instance' do

        expect(
          Dense::Path.new('a["b","B"].c.d')[1, 1]
        ).to eq(
          Dense::Path.new('["b","B"]')
        )
      end
    end
  end

  describe '#to_s' do

    {

      '0.name'         => '0.name',
      'name.0'         => 'name.0',
      '11[0]'          => '11.0',
      "name.first"     => 'name.first',
      "name['first']"  => 'name.first',
      'name["last"]'   => 'name.last',
      'name[0]'        => 'name.0',
      '[0].name'       => '0.name',

      '.name'        => '.name',
      '.["name"]'    => '.name',
      'store..name'  => 'store..name',

      'name[*]'    => 'name.*',
      'name[::1]'  => 'name[::1]',

      'name.*' => 'name.*',
      'name.[*]' => 'name..*',

      '.*' => '.*',
      '.[*]' => '.*',
      'name..*' => 'name..*',

      'name..[*]' => 'name..*',
      'name...something' => 'name..something',

      'x..y...z' => 'x..y..z',

      '[\'name\',"age"]'   => '["name","age"]',
      'x[\'name\',"age"]'  => 'x["name","age"]',

      '11.name'       => '11.name',
      '11["name"]'    => '11.name',
      '11[age]'       => '11.age',
      '11[name,age]'  => '11["name","age"]',
      '11["name",]'   => '11["name",]',
      '11[0,]'        => '11[0,]',

      '[1:2,10:20,99]' => '[1:2,10:20,99]',

      'x["name\'+-.nada"]'  => 'x["name\'+-.nada"]',
      "x['name\"+-.nada']"  => 'x["name\\"+-.nada"]',

      '+' => '+',
      '-' => '-',
      '/' => '/',
      '%' => '%',
      '>' => '>',
      '<' => '<',
      '=' => '=',
      '?' => '?',

      '*'  => '*',
      '\*' => '\*',
      '\.' => '\.',

      'aAbZ/\0-9^' => 'aAbZ/\0-9^',

      'x./(id|name)/' => 'x./(id|name)/',
      'x[/(id|name)/,y]' => 'x[/(id|name)/,"y"]',
      'x./(id|name)/xu' => 'x./(id|name)/xu',
      'x./(id|name)/xn' => 'x./(id|name)/xn',
      'x./(id|名前)/x' => 'x./(id|名前)/xu',

    }.each do |path, result|

      it "turns #{path} into #{result}" do

        pa = Dense::Path.new(path)

        expect(pa.to_s).to eq(result)
      end
    end
  end
end

