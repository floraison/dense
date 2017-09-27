
#
# Specifying dense
#
# Tue Sep  5 17:35:03 JST 2017
#

require 'spec_helper'


describe Dense do

    before :all do

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
              '7' => 'seven'
            }
          }
        }
    end

  describe '.get' do

    [

      [ 'store.book.1.title',
        'Sword of Honour' ],

      [ 'store.book.*.title',
        [ 'Sayings of the Century', 'Sword of Honour', 'Moby Dick',
          'The Lord of the Rings'] ],

      [ 'store.bicycle.7',
        'seven' ],

    ].each do |path, result|

      it "gets #{path.inspect}" do

        expect(Dense.get(@data, path)).to eq(result)
      end
    end

    it 'returns nil if it cannot find' do

      expect(Dense.get(@data, 'nada.inferno')).to eq(nil)
    end

    it 'returns nil if it cannot find' do

      expect(Dense.get({}, 'a.0.b')).to eq(nil)
    end
  end

  describe '.fetch' do

    [

      [ 'store.book.1.title',
        'Sword of Honour' ],

      [ 'store.book.*.title',
        [ 'Sayings of the Century', 'Sword of Honour', 'Moby Dick',
          'The Lord of the Rings'] ],

      [ 'store.bicycle.7',
        'seven' ],

    ].each do |path, result|

      it "fetches #{path.inspect}" do

        expect(Dense.fetch(@data, path)).to eq(result)
      end
    end

    it 'raises a KeyError if it cannot find' do

      expect {
        Dense.fetch({}, 'a.0.b')
      }.to raise_error(
        KeyError, 'Found nothing at "a" ("0.b" remains)'
      )
    end

    it 'returns the given default value if it cannot find' do

      expect(
        Dense.fetch({}, 'a.0.b', -1)
      ).to eq(-1)
    end

    it 'returns the value of the given block if it cannot find' do

      a = -2

      expect(
        Dense.fetch({}, 'a.0.b') { a }
      ).to eq(-2)
    end
  end

  describe '.set' do

    it 'sets at the first level' do

      o = {}
      r = Dense.set(o, 'a', 1)

      expect(o).to eq({ 'a' => 1 })
      expect(r).to eq(1)
    end

    it 'sets at the second level in a hash' do

      o = { 'h' => {} }
      r = Dense.set(o, 'h.i', 1)

      expect(o).to eq({ 'h' => { 'i' => 1 } })
      expect(r).to eq(1)
    end

    it 'sets at the second level in an array ' do

      o = { 'a' => [ 1, 2, 3 ] }
      r = Dense.set(o, 'a.1', 1)

      expect(o).to eq({ 'a' => [ 1, 1, 3 ] })
      expect(r).to eq(1)
    end

    it 'sets array first' do

      o = { 'h' => { 'a' => [ 1, 2, 3 ] } }
      r = Dense.set(o, 'h.a.first', 'one')

      expect(o).to eq({ 'h' => { 'a' => [ "one", 2, 3 ] } })
      expect(r).to eq('one')
    end

    it 'sets array last' do

      o = { 'h' => { 'a' => [ 1, 2, 3 ] } }
      r = Dense.set(o, 'h.a.last', 'three')

      expect(o).to eq({ 'h' => { 'a' => [ 1, 2, 'three' ] } })
      expect(r).to eq('three')
    end

    it 'fails if it cannot set (mismatch)' do

      c = { 'a' => [] }

      expect {
        Dense.set(c, 'a.b', 1)
      }.to raise_error(
        IndexError, 'Cannot index array at "b"'
      )

      expect(c).to eq({ 'a' => [] })
    end

    it 'turns a int index into a string key when setting in a Hash' do

      c = { 'a' => {} }

      Dense.set(c, 'a.1', 1)

      expect(c).to eq({ 'a' => { '1' => 1 } })
    end

    it 'fails if it cannot set (no coll 2)' do

      c = {}

      expect {
        Dense.set(c, 'a.0', 1)
      }.to raise_error(
        IndexError, 'Found no collection at "a"'
      )

      expect(c).to eq({})
    end
  end

  describe '.unset' do

    [

      [ { 'a' => 1 }, 'a', 1, {} ],
      [ { 'h' => { 'i' => 1 } }, 'h.i', 1, { 'h' => {} } ],
      [ { 'a' => [ 1, 2, 3 ] }, 'a.1', 2, { 'a' => [ 1, 3 ] } ],

      [ { 'h' => { 'a' => [ 1, 2, 3 ] } },
        'h.a.first',
        1,
        { 'h' => { 'a' => [ 2, 3 ] } } ],

      [ { 'h' => { 'a' => [ 1, 2, 3 ] } },
        'h.a.last',
        3,
        { 'h' => { 'a' => [ 1, 2 ] } } ],

    ].each do |col0, path, result, col1|

      it "unsets #{path.inspect}" do

        r = Dense.unset(col0, path)

        expect(r).to eq(result)
        expect(col0).to eq(col1)
      end
    end

    it 'fails if it cannot unset in a Hash' do

      expect {
        Dense.unset({}, 'a')
      }.to raise_error(
        IndexError, 'No key "a" for hash'
      )
    end

    it 'fails if it cannot unset in a Array' do

      expect {
        Dense.unset([], 'a')
      }.to raise_error(
        IndexError, 'Cannot index array at "a"'
      )
    end

    it 'fails if it cannot unset in a Array (2)' do

      expect {
        Dense.unset([], '1')
      }.to raise_error(
        IndexError, 'Array has length of 0, index is at 1'
      )
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
        IndexError, 'Found no collection at "a"'
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

  describe '.has_path?' do
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

