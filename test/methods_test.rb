
#
# Testing dense
#
# Tue Sep  5 17:35:03 JST 2017
#


group Dense do

  before do

    @data = # taken from http://goessner.net/articles/JsonPath/
      { 'store' => {
          'book' => [
            { 'category' => 'reference',
              'author' => 'Nigel Rees',
              'title' => 'Sayings of the Century',
              'price' => 8.95
            },
            { 'category' => 'fiction',
              'author' => 'Evelyn Waugh',
              'title' => 'Sword of Honour',
              'price' => 12.99
            },
            { 'category' => 'fiction',
              'author' => 'Herman Melville',
              'title' => 'Moby Dick',
              'isbn' => '0-553-21311-3',
              'price' => 8.99
            },
            { 'category' => 'fiction',
              'author' => 'J. R. R. Tolkien',
              'title' => 'The Lord of the Rings',
              'isbn' => '0-395-19395-8',
              'price' => 22.99
            }
          ],
          'bicycle' => {
            'color' => 'red',
            'price' => 19.95,
            '7' => 'seven',
            '8' => [ 'ei', 'gh', 't' ]
          }
        }
      }
  end

  group '.paths' do

    {

      '..janitor' => [
        ],
      '..author' => %w[
        store.book.0.author store.book.1.author store.book.2.author
        store.book.3.author ],
      'store..author' => %w[
        store.book.0.author store.book.1.author store.book.2.author
        store.book.3.author ],

    }.each do |glob, result|

      test "for #{glob.inspect} yields #{result.inspect}" do

        assert Dense.paths(@data, glob), result
      end
    end
  end

  group '.get' do

    {

      'store.book.1.title' =>
        'Sword of Honour',
      'store.book[1,2].title' =>
        [ 'Sword of Honour', 'Moby Dick' ],
      'store.book.*.title' =>
        [ 'Sayings of the Century', 'Sword of Honour', 'Moby Dick',
          'The Lord of the Rings' ],
      'store.bicycle.7' =>
        'seven',
      'store.bicycle[7]' =>
        'seven',
      'store.bicycle.8' =>
        %w[ ei gh t ],
      'store.bicycle.8.last' =>
        't',

      [ 'store', 'book', 1, 'title' ] =>
        'Sword of Honour',

    }.each do |path, result|

      test "gets #{path.inspect}" do

        assert Dense.get(@data, path), result
      end
    end

    [

      'nada.inferno',
      'store.bicycle.seven',
      'store.bicycle[seven]',
      'store.bicycle["seven"]',
      'store.book.999',

      [ 'store', 'book', -999 ],

    ].each do |path|

      test "returns nil if test cannot find #{path.inspect}" do

        assert_nil Dense.get(@data, path)
      end
    end

    test 'interprets "0_1_2" as a \'name\' index, not as "0"...' do

      data = { 'replies' => { '0_1_2' => { 'lol' => true } } }

      assert Dense.get(data, 'replies.0_1_2'), { 'lol' => true }
    end
  end

  group '.fetch' do

    {

      'store.book.1.title' =>
        'Sword of Honour',

      'store.book.*.title' =>
        [ 'Sayings of the Century', 'Sword of Honour', 'Moby Dick',
          'The Lord of the Rings' ],

      'store.bicycle.7' =>
        'seven',

      'store.bicycle[7]' =>
        'seven',

      [ 'store', 'bicycle', 7 ] =>
        'seven',

    }.each do |path, result|

      test "fetches #{path.inspect}" do

        assert Dense.fetch(@data, path), result
      end
    end

    {

      'a.0.b' =>
        [ KeyError, 'found nothing at "a" ("0.b" remains)' ],
      'store.0.b' =>
        [ KeyError, 'found nothing at "store.0" ("b" remains)' ],
      'store.bike.b' =>
        [ KeyError, 'found nothing at "store.bike" ("b" remains)' ],
      'store.bicycle.seven' =>
        [ KeyError, 'found nothing at "store.bicycle.seven"' ],
      'store.bicycle[seven]' =>
        [ KeyError, 'found nothing at "store.bicycle.seven"' ],
      'store.bicycle["seven"]' =>
        [ KeyError, 'found nothing at "store.bicycle.seven"' ],
      [ 'store', 'bicycle', 'seven' ] =>
        [ KeyError, 'found nothing at "store.bicycle.seven"' ],

      'store.bicycle.color.tone' =>
        [ IndexError, 'found no collection at "store.bicycle.color" for key "tone"' ],

    }.each do |path, (error_klass, error_message)|

      test "raises a #{error_klass} if test cannot find #{path.inspect}" do

#p begin; Dense.fetch(@data, path); rescue => e; e.miss; end
        assert_error(
          lambda { Dense.fetch(@data, path) },
          error_klass, error_message)
      end
    end

    {

      [ 'a.0.b', -1 ] => -1,
      [ 'store.nada', 'x' ] => 'x',
      [ 'a.0.b', lambda { |coll, path| -2 } ] => -2,
      [ 'store.bicycle.seven', -3 ] => -3,
      [ 'store.bicycle.seven', false ] => false,
      [ 'store.bicycle.seven', lambda { |coll, path| -3 } ] => -3,
      [ [ 'store', 'bicycle', 'seven' ], -3 ] => -3,

    }.each do |(path, default), result|

      test "returns the given default #{default.inspect}" do

        assert(
          if default.is_a?(::Proc)
            Dense.fetch(@data, path, &default)
          else
            Dense.fetch(@data, path, default)
          end,
          result)
      end
    end

    test 'ignores the block if not necessary' do

      assert(
        Dense.fetch(@data, 'store.book.1.title') do |coll, path|
          "len:#{coll.length},path:#{path}"
        end,
        'Sword of Honour')
    end

    test 'returns the given block default' do

      assert(
        Dense.fetch(@data, 'store.bicycle.otto') do |c, p, p0, c0, p1|
          "c:#{c.length},p:#{p},p0:#{p0.to_s},c0:#{c0.length},p1:#{p1.to_s}"
        end,
        'c:1,p:store.bicycle.otto,p0:store.bicycle,c0:4,p1:otto')
    end

    test 'enhances KeyError' do

      err =
        begin
          Dense.fetch({}, 'a')
        rescue => e
          e
        end

      assert err.class, KeyError
      assert err.message, 'found nothing at "a"'
      assert err.full_path, 'a'
      assert err.miss, [ false, [], {}, 'a', [] ]
    end

    test 'enhances TypeError' do

      err =
        begin
          Dense.fetch({ 'a' => [] }, 'a.b')
        rescue => e
          e
        end

      assert err.class, TypeError
      assert err.message, 'no key "b" for Array at "a"'
      assert err.full_path, 'a.b'
      assert err.miss, [ false, [ 'a' ], [], 'b', [] ]
    end

    test 'returns nil when the value is nil' do

      r = Dense.fetch({ 'a' => nil }, 'a')

      assert_nil r
    end
  end

  group '.set' do

    test 'sets at the first level' do

      c = {}
      r = Dense.set(c, 'a', 1)

      assert c, { 'a' => 1 }
      assert r, 1
    end

    test 'sets at the second level in a hash' do

      c = { 'h' => {} }
      r = Dense.set(c, 'h.i', 1)

      assert c, { 'h' => { 'i' => 1 } }
      assert r, 1
    end

    test 'sets at the second level in an array ' do

      c = { 'a' => [ 1, 2, 3 ] }
      r = Dense.set(c, 'a.1', 1)

      assert c, { 'a' => [ 1, 1, 3 ] }
      assert r, 1
    end

    test 'sets array first' do

      c = { 'h' => { 'a' => [ 1, 2, 3 ] } }
      r = Dense.set(c, 'h.a.first', 'one')

      assert c, { 'h' => { 'a' => [ "one", 2, 3 ] } }
      assert r, 'one'
    end

    test 'sets array last' do

      c = { 'h' => { 'a' => [ 1, 2, 3 ] } }
      r = Dense.set(c, 'h.a.last', 'three')

      assert c, { 'h' => { 'a' => [ 1, 2, 'three' ] } }
      assert r, 'three'
    end

    test 'sets with an array path' do

      c = { 'h' => { 'a' => [ 1, 2, 3 ] } }
      r = Dense.set(c, [ 'h', 'a', 'last' ], 'three')

      assert c, { 'h' => { 'a' => [ 1, 2, 'three' ] } }
      assert r, 'three'
    end

    test 'fails if test cannot set (mismatch)' do

      c = { 'a' => [] }

      assert_error(
        lambda { Dense.set(c, 'a.b', 1) },
        TypeError, 'no key "b" for Array at "a"')

      assert c, { 'a' => [] }
    end

    test 'turns a int index into a string key when setting in a Hash' do

      c = { 'a' => {} }
      r = Dense.set(c, 'a.1', 1)

      assert c, { 'a' => { '1' => 1 } }
      assert r, 1
    end

    test 'fails if test cannot set (no coll 2)' do

      c = {}

      assert_error(
        lambda { Dense.set(c, 'a.0', 1) },
        KeyError, 'found nothing at "a" ("0" remains)')

      assert c, {}
    end

    test 'enhances KeyError' do

      err =
        begin
          Dense.set({}, 'a.b', 1234)
        rescue => e
          e
        end

      assert err.class, KeyError
      assert err.message, 'found nothing at "a" ("b" remains)'
      assert err.full_path, 'a.b'
      assert err.miss, [ false, [], {}, 'a', [ 'b' ] ]
    end

    test 'enhances TypeError' do

      err =
        begin
          Dense.set({ 'a' => [] }, 'a.b', 1234)
        rescue => e
          e
        end

      assert err.class, TypeError
      assert err.message, 'no key "b" for Array at "a"'
      assert err.full_path, 'a.b'
      assert err.miss, [ false, [ 'a' ], [], 'b', [] ]
    end
  end

  group '.unset' do

    [

      [ { 'a' => 1 },
        'a',
        1,
        {} ],

      [ { 'a' => [ 1, 2, 3 ] },
        'a.1',
        2,
        { 'a' => [ 1, 3 ] } ],

      [ { 'h' => { 'a' => [ 1, 2, 3 ] } },
        'h.a.first',
        1,
        { 'h' => { 'a' => [ 2, 3 ] } } ],

      [ { 'h' => { 'a' => [ 1, 2, 3 ] } },
        'h.a.last',
        3,
        { 'h' => { 'a' => [ 1, 2 ] } } ],

      [ { 'h' => { 'a' => [ 1, 2, 3, 4, 5, 'six' ] } },
        'h.a[2:4]',
        [ 3, 4, 5 ],
        { 'h' => { 'a' => [ 1, 2, 'six' ] } } ],

      [ { 'h' => { 'a' => [ 1, 2, 3, 4, 5, 'six' ] } },
        [ 'h', 'a', { start: 2, end: 4, step: 1 } ],
        [ 3, 4, 5 ],
        { 'h' => { 'a' => [ 1, 2, 'six' ] } } ],

    ].each do |col0, path, result, col1|

      test "unsets (in array) #{path.inspect}" do

        r = Dense.unset(col0, path)

        assert r, result
        assert col0, col1
      end
    end

    [

      [ { 'h' => { 'i' => 1 } },
        'h.i',
        1,
        { 'h' => {} } ],

      [ { 'h' => { 'i' => 1, 'j' => 2, 'k' => 3 } },
        'h[i,k]',
        [ 1, 3 ],
        { 'h' => { 'j' => 2 } } ],

      [ { 'h' => { 'i' => 1, 'j' => 2, 'k' => 3 } },
        'h["i","k"]',
        [ 1, 3 ],
        { 'h' => { 'j' => 2 } } ],

      [ { 'h' => { 'i' => 1, 'j' => 2, 'k' => 3 } },
        [ 'h', [ 'i', 'k' ] ],
        [ 1, 3 ],
        { 'h' => { 'j' => 2 } } ],

    ].each do |col0, path, result, col1|

      test "unsets (in hash) #{path.inspect}" do

        r = Dense.unset(col0, path)

        assert r, result
        assert col0, col1
      end
    end

    [

      [ {}, 'a', KeyError, 'found nothing at "a"' ],
      [ [], 'a', TypeError, 'no key "a" for Array at root' ],
      [ [], '1', KeyError, 'found nothing at "1"' ],

      [ { 'a' => [] }, 'a.b',
        TypeError, 'no key "b" for Array at "a"' ],
      [ { 'a' => {} }, 'a.1',
        KeyError, 'found nothing at "a.1"' ],
      [ { 'a' => {} }, 'a.1.c',
        KeyError, 'found nothing at "a.1" ("c" remains)' ],

      [ { 'a' => {} }, [ 'a', 1, 'c' ],
        KeyError, 'found nothing at "a.1" ("c" remains)' ],

    ].each do |col, path, err_class, err_msg|

      test "fails with #{err_msg.inspect}" do

        assert_error(lambda { Dense.unset(col, path) }, err_class, err_msg)
      end
    end

    test 'does not fail if nofail=true' do

      data = { 'a' => 'A', 'b' => 'B', 'd' => 'D' }

      assert_error(
        lambda { Dense.unset(data, '[a,b,c]', false) },
        KeyError, 'found nothing at "c"')

      assert data, { 'a' => 'A', 'b' => 'B', 'd' => 'D' }

      r = Dense.unset(data, '[a,b,c]', true)

      assert r, [ 'A', 'B', nil ]
      assert data, { 'd' => 'D' }
    end

    test 'enhances KeyError' do

      err =
        begin
          Dense.unset({}, 'a')
        rescue => e
          e
        end

      assert err.class, KeyError
      assert err.message, 'found nothing at "a"'
      assert err.full_path, 'a'
      assert err.miss, [ false, [], {}, 'a', [] ]
    end

    test 'enhances TypeError' do

      err =
        begin
          Dense.unset({ 'a' => [] }, 'a.b')
        rescue => e
          e
        end

      assert err.class, TypeError
      assert err.message, 'no key "b" for Array at "a"'
      assert err.full_path, 'a.b'
      assert err.miss, [ false, [ 'a' ], [], 'b', [] ]
    end
  end

  group '.force_set' do

    test 'sets' do

      c = {}
      r = Dense.force_set(c, 'a', 1)

      assert c, { 'a' => 1 }
      assert r, 1
    end

    test 'creates the necessary arrays' do

      c = {}
      r = Dense.force_set(c, 'a.0', 1)

      assert c, { 'a' => [ 1 ] }
      assert r, 1
    end

    test 'creates the necessary hashes' do

      c = {}
      r = Dense.force_set(c, 'a.b', 1)

      assert c, { 'a' => { 'b' => 1 } }
      assert r, 1
    end

    test 'creates the necessary collections' do

      c = {}
      r = Dense.force_set(c, 'a.b.3.d.0', 1)

      assert c, { 'a' => { 'b' => [ nil, nil, nil, { 'd' => [ 1 ] } ] } }
      assert r, 1
    end

    test 'fails if test cannot set' do


      c = { 'a' => [] }

      err =
        begin
          Dense.force_set(c, 'a.b', 1)
        rescue => e
          e
        end

      assert err.class, TypeError
      assert err.message, 'no key "b" for Array at "a"'
      assert err.full_path, 'a.b'
      assert err.miss, [ false, [ 'a' ], [], 'b', [] ]
    end
  end

  group '.insert' do

    [

      [ {}, 'a', 1,
        { 'a' => 1 } ],

      [ { 'h' => {} }, 'h.i', 1,
        { 'h' => { 'i' => 1 } } ],

      [ { 'a' => [ 1, 2, 3 ] }, 'a.1', 1,
        { 'a' => [ 1, 1, 2, 3 ] } ],

      [ { 'a' => [ 'one', [ 2, 3, 4 ], 'three' ] }, 'a.1.first', 1,
        { 'a' => [ 'one', [ 1, 2, 3, 4 ], 'three' ] } ],

      [ { 'a' => [ 'one', [ 2, 3, 4 ], 'three' ] }, 'a.1.last', 5,
        { 'a' => [ 'one', [ 2, 3, 4, 5 ], 'three' ] } ],

      [ { 'a' => [ 'one', [ 2, 3, 4 ], 'three' ] }, [ 'a', 1, 'last' ], 5,
        { 'a' => [ 'one', [ 2, 3, 4, 5 ], 'three' ] } ],

    ].each do |col, path, value, col1|

      test "inserts at #{path.inspect}" do

        r = Dense.insert(col, path, value)

        assert col, col1
        assert r, value
      end
    end

    test 'fails if test cannot insert' do

      assert_error(
        lambda { Dense.insert({}, 'a.b', 1) },
        KeyError, 'found nothing at "a" ("b" remains)')
    end

    test 'fails if test cannot insert into an array' do

      assert_error(
        lambda { Dense.insert([], 'a', 1) },
        TypeError, 'no key "a" for Array at root')
    end

    test 'enhances KeyError' do

      err =
        begin
          Dense.insert({}, 'a.b', 1234)
        rescue => e
          e
        end

      assert err.class, KeyError
      assert err.message, 'found nothing at "a" ("b" remains)'
      assert err.full_path, 'a.b'
      assert err.miss, [ false, [], {}, 'a', [ 'b' ] ]
    end

    test 'enhances TypeError' do

      err =
        begin
          Dense.insert({ 'a' => [] }, 'a.b', 1234)
        rescue => e
          e
        end

      assert err.class, TypeError
      assert err.message, 'no key "b" for Array at "a"'
      assert err.full_path, 'a.b'
      assert err.miss, [ false, [ 'a' ], [], 'b', [] ]
    end
  end

  group '.has_key?' do

    setup do

      @cars = {
        'alpha' => { 'id' => 'FR1' },
        'bentley' => %w[ blower spur markv ] }
    end

    [

      [ 'nada', false ],
      [ 'alpha.nada', false ],
      [ 'bentley.nada', false ],
      [ 'bentley.3', false ],
      [ 'bentley.-4', false ],
      [ [ 'bentley', -4 ], false ],

      [ 'alpha', true ],
      [ 'alpha.id', true ],
      [ 'bentley', true ],
      [ 'bentley.0', true ],
      [ 'bentley.-1', true ],
      [ 'bentley.first', true ],
      [ 'bentley.last', true ],
      [ [ 'bentley', 'last' ], true ],

    ].each do |path, result|

      test "works for #{path.inspect} (#{result})" do

        assert Dense.has_key?(@cars, path), result
      end
    end

    test 'works with stringified int keys' do

      assert Dense.has_key?({ '7' => 'seven' }, '7')
    end
  end
end

