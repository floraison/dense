# encoding: UTF-8

#
# Testing dense
#
# Sun Aug  6 08:04:41 JST 2017
#


group Dense::Path do

  group '.new' do

    test "fails if the input path is not a String" do

      assert_error(
        lambda { Dense::Path.new(1) },
        ArgumentError, /\Aargument is a (Integer|Fixnum), not a String\z/)
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
      '0_1_2'          => [ '0_1_2' ],

      '.name'        => [ :dot, 'name' ],
      '.["name"]'    => [ :dot, 'name' ],
      'store..name'  => [ 'store', :dot, 'name' ],

      'name.*'         => [ 'name', :star ],
      'name[*]'        => [ 'name', :star ],
      'name[::1]'      => [ 'name', { start: nil, end: nil, step: 1 } ],
      'book[*].title'  => [ 'book', :star, 'title' ],
      'name.[*]'       => [ 'name', :dotstar ],
      'name..*'        => [ 'name', :dotstar ],

      'name[::1;3,4].a' => [
        'name',
        [ { start: nil, end: nil, step: 1 }, { start: 3, count: 4 } ],
        'a' ],

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
      '11[0,]'        => [ 11, 0 ],
      '11[0,2]'       => [ 11, { start: 0, count: 2 } ],
      '11[0,;3]'      => [ 11, [ 0, 3 ] ],

      '[1:2,10:20,99]' => [
        [ { start: 1, end: 2, step: nil },
          { start: 10, end: 20, step: nil },
          99 ] ],
      '[1:2;10:20;99]' => [
        [ { start: 1, end: 2, step: nil },
          { start: 10, end: 20, step: nil },
          99 ] ],
      '[1:2;10:20;99;1,2]' => [
        [ { start: 1, end: 2, step: nil },
          { start: 10, end: 20, step: nil },
          99,
          { start: 1, count: 2 } ] ],

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

      '==' => [ '==' ],
      '!=' => [ '!=' ],

    }.each do |s, a|

      test "parses #{s.inspect}" do
      #test "parses #{s.inspect} to #{a.inspect}" do

        assert Dense::Path.new(s).to_a, a
      end
    end
  end

  group '.make' do

    {

      [ 'a', 'b', 'c' ] =>
        'a.b.c',
      [ 'a', :star, 'c' ] =>
        'a.*.c',
      [ 'a', { start: 2, count: 3 }, 'c' ] =>
        'a[2,3].c',
      [ 'a', { 'start' => 2, 'count' => 3 }, 'c' ] =>
        'a[2,3].c',

    }.each do |array, path|

      test "creates a Dense::Path instance from #{array.inspect}" do

        assert Dense::Path.make(array).to_s, path
      end
    end

    {

      [ 'a', 'b', { nada: true } ] =>
         [ TypeError, /not a path element \(@2\): / ],
      [ 'a', :deathstar, 'c' ] =>
         [ TypeError, 'not a path element (@1): :deathstar' ],

    }.each do |array, (klass, message)|

      test "fails for #{array.inspect}" do

        assert_error(
          lambda { Dense::Path.make(array) },
          klass, message)
      end
    end
  end

  group '#[]' do

    group '(int)' do

      test 'returns a key' do

        assert Dense::Path.new('a.b.c.d')[1], 'b'
      end

      test 'returns a key' do

        assert Dense::Path.new('a["b","B"].c.d')[1], %w[ b B ]
      end
    end

    group '(int..int)' do

      test 'returns a Path instance' do

        assert(
          Dense::Path.new('a.b.c.d')[1..2],
          Dense::Path.new('b.c'))
      end
    end

    group '(int, int)' do

      test 'returns a Path instance' do

        assert(
          Dense::Path.new('a["b","B"].c.d')[1, 1],
          Dense::Path.new('["b","B"]'))
      end
    end
  end

  group '#to_s' do

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

      '[\'name\',"age"]'   => '["name";"age"]',
      'x[\'name\',"age"]'  => 'x["name";"age"]',
      '[\'name\';"age"]'   => '["name";"age"]',
      'x[\'name\';"age"]'  => 'x["name";"age"]',

      '11.name'       => '11.name',
      '11["name"]'    => '11.name',
      '11[age]'       => '11.age',
      '11[name,age]'  => '11["name";"age"]',
      '11["name",]'   => '11["name";]',
      '11["name";]'   => '11["name";]',
      '11[0,]'        => '11.0',
      '11[0;]'        => '11[0;]',
      '11[0,;]'       => '11[0;]',
      '11[0,2]'       => '11[0,2]',
      '11[0;2]'       => '11[0;2]',

      '[1:2,10:20,99]' => '[1:2;10:20;99]',
      '[1:2;10:20;99]' => '[1:2;10:20;99]',

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
      'x[/(id|name)/,y]' => 'x[/(id|name)/;"y"]',
      'x./(id|name)/xu' => 'x./(id|name)/xu',
      'x./(id|name)/xn' => 'x./(id|name)/xn',
      'x./(id|名前)/x' => 'x./(id|名前)/xu',

    }.each do |path, result|

      test "turns #{path} into #{result}" do

        pa = Dense::Path.new(path)

        assert pa.to_s, result
      end
    end
  end
end

