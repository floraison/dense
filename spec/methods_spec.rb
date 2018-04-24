
#
# Specifying dense
#
# Tue Sep  5 17:35:03 JST 2017
#

require 'spec_helper'


describe Dense do

  before :each do

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

  describe '.get' do

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
      'store.bicycle.8' =>
        %w[ ei gh t ],
      'store.bicycle.8.last' =>
        't',

    }.each do |path, result|

      it "gets #{path.inspect}" do

        expect(Dense.get(@data, path)).to eq(result)
      end
    end

    [
      'nada.inferno',
      'store.bicycle.seven',
      'store.bicycle[seven]',
      'store.bicycle["seven"]',
      'store.book.999',
    ].each do |path|

      it "returns nil if it cannot find #{path.inspect}" do

        expect(Dense.get(@data, path)).to eq(nil)
      end
    end
  end

  describe '.fetch' do

    [

      [ 'store.book.1.title',
        'Sword of Honour' ],

      [ 'store.book.*.title',
        [ 'Sayings of the Century', 'Sword of Honour', 'Moby Dick',
          'The Lord of the Rings' ] ],

      [ 'store.bicycle.7',
        'seven' ],

      [ 'store.bicycle[7]',
        'seven' ],

    ].each do |path, result|

      it "fetches #{path.inspect}" do

        expect(Dense.fetch(@data, path)).to eq(result)
      end
    end

    [

      [ 'a.0.b',
        KeyError, 'Found nothing at "a" ("0.b" remains)' ],
      [ 'store.0.b',
        KeyError, 'Found nothing at "store.0" ("b" remains)' ],
      [ 'store.bike.b',
        KeyError, 'Found nothing at "store.bike" ("b" remains)' ],
      [ 'store.bicycle.seven',
        KeyError, 'Found nothing at "store.bicycle.seven"' ],
      [ 'store.bicycle[seven]',
        KeyError, 'Found nothing at "store.bicycle.seven"' ],
      [ 'store.bicycle["seven"]',
        KeyError, 'Found nothing at "store.bicycle.seven"' ],

    ].each do |path, error_klass, error_message|

      it "raises a #{error_klass} if it cannot find #{path.inspect}" do

        expect {
          Dense.fetch(@data, path)
        }.to raise_error(
          error_klass, error_message
        )
      end
    end

    [

      [ 'a.0.b', -1, -1 ],
      [ 'store.nada', 'x', 'x' ],
      [ 'a.0.b', lambda { |coll, path| -2 }, -2 ],
      [ 'store.bicycle.seven', -3, -3 ],
      [ 'store.bicycle.seven', false, false ],
      [ 'store.bicycle.seven', lambda { |coll, path| -3 }, -3 ],

    ].each do |path, default, result|

      it "returns the given default #{default.inspect}" do

        expect(
          if default.is_a?(::Proc)
            Dense.fetch(@data, path, &default)
          else
            Dense.fetch(@data, path, default)
          end
        ).to eq(result)
      end
    end

    it 'ignores the block if not necessary' do

      expect(
        Dense.fetch(@data, 'store.book.1.title') do |coll, path|
          "len:#{coll.length},path:#{path}"
        end
      ).to eq('Sword of Honour')
    end

    it 'returns the given block default' do

      expect(
        Dense.fetch(@data, 'store.bicycle.otto') do |c, p, p0, c0, p1|
          "c:#{c.length},p:#{p},p0:#{p0.to_s},c0:#{c0.length},p1:#{p1.to_s}"
        end
      ).to eq(
        'c:1,p:store.bicycle.otto,p0:store.bicycle,c0:4,p1:otto'
      )
    end
  end

  describe '.set' do

    it 'sets at the first level' do

      c = {}
      r = Dense.set(c, 'a', 1)

      expect(c).to eq({ 'a' => 1 })
      expect(r).to eq(1)
    end

    it 'sets at the second level in a hash' do

      c = { 'h' => {} }
      r = Dense.set(c, 'h.i', 1)

      expect(c).to eq({ 'h' => { 'i' => 1 } })
      expect(r).to eq(1)
    end

    it 'sets at the second level in an array ' do

      c = { 'a' => [ 1, 2, 3 ] }
      r = Dense.set(c, 'a.1', 1)

      expect(c).to eq({ 'a' => [ 1, 1, 3 ] })
      expect(r).to eq(1)
    end

    it 'sets array first' do

      c = { 'h' => { 'a' => [ 1, 2, 3 ] } }
      r = Dense.set(c, 'h.a.first', 'one')

      expect(c).to eq({ 'h' => { 'a' => [ "one", 2, 3 ] } })
      expect(r).to eq('one')
    end

    it 'sets array last' do

      c = { 'h' => { 'a' => [ 1, 2, 3 ] } }
      r = Dense.set(c, 'h.a.last', 'three')

      expect(c).to eq({ 'h' => { 'a' => [ 1, 2, 'three' ] } })
      expect(r).to eq('three')
    end

    it 'fails if it cannot set (mismatch)' do

      c = { 'a' => [] }

      expect {
        Dense.set(c, 'a.b', 1)
      }.to raise_error(
        TypeError, 'No key "b" for Array at "a"'
      )

      expect(c).to eq({ 'a' => [] })
    end

    it 'turns a int index into a string key when setting in a Hash' do

      c = { 'a' => {} }
      r = Dense.set(c, 'a.1', 1)

      expect(c).to eq({ 'a' => { '1' => 1 } })
      expect(r).to eq(1)
    end

    it 'fails if it cannot set (no coll 2)' do

      c = {}

      expect {
        Dense.set(c, 'a.0', 1)
      }.to raise_error(
        KeyError, 'Found nothing at "a" ("0" remains)'
      )

      expect(c).to eq({})
    end
  end

  describe '.unset' do

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

    ].each do |col0, path, result, col1|

      it "unsets (in array) #{path.inspect}" do

        r = Dense.unset(col0, path)

        expect(r).to eq(result)
        expect(col0).to eq(col1)
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

    ].each do |col0, path, result, col1|

      it "unsets (in hash) #{path.inspect}" do

        r = Dense.unset(col0, path)

        expect(r).to eq(result)
        expect(col0).to eq(col1)
      end
    end

    [

      [ {}, 'a', KeyError, 'Found nothing at "a"' ],
      [ [], 'a', TypeError, 'No key "a" for Array at root' ],
      [ [], '1', KeyError, 'Found nothing at "1"' ],

      [ { 'a' => [] }, 'a.b',
        TypeError, 'No key "b" for Array at "a"' ],
      [ { 'a' => {} }, 'a.1',
        KeyError, 'Found nothing at "a.1"' ],
      [ { 'a' => {} }, 'a.1.c',
        KeyError, 'Found nothing at "a.1" ("c" remains)' ],

    ].each do |col, path, err_class, err_msg|

      it "fails with #{err_msg.inspect}" do

        expect { Dense.unset(col, path) }
          .to raise_error(err_class, err_msg)
      end
    end

    it 'does not fail if nofail=true' do

      data = { 'a' => 'A', 'b' => 'B', 'd' => 'D' }

      expect {
        Dense.unset(data, '[a,b,c]', false)
      }.to raise_error(
        KeyError, 'Found nothing at "c"'
      )
      expect(data).to eq({ 'a' => 'A', 'b' => 'B', 'd' => 'D' })

      r = Dense.unset(data, '[a,b,c]', true)

      expect(r).to eq([ 'A', 'B', nil ])
      expect(data).to eq({ 'd' => 'D' })
    end
  end

  describe '.insert' do

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

    ].each do |col, path, value, col1|

      it "inserts at #{path.inspect}" do

        r = Dense.insert(col, path, value)

        expect(col).to eq(col1)
        expect(r).to eq(value)
      end
    end

    it 'fails if it cannot insert' do

      expect {
        Dense.insert({}, 'a.b', 1)
      }.to raise_error(
        Dense::Path::NotIndexableError, 'Found nothing at "a"'
      )
    end

    it 'fails if it cannot insert into an array' do

      expect {
        Dense.insert([], 'a', 1)
      }.to raise_error(
        IndexError, 'Cannot index array at "a"'
      )
    end
  end

  describe '.has_key?' do

    before :all do

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

      [ 'alpha', true ],
      [ 'alpha.id', true ],
      [ 'bentley', true ],
      [ 'bentley.0', true ],
      [ 'bentley.-1', true ],
      [ 'bentley.first', true ],
      [ 'bentley.last', true ],

    ].each do |path, result|

      it "works for #{path.inspect} (#{result})" do

        expect(Dense.has_key?(@cars, path)).to eq(result)
      end
    end

    it 'works with stringified int keys' do

      expect(
        Dense.has_key?({ '7' => 'seven' }, '7')
      ).to be true
    end
  end
end

