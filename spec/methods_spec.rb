
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
              'price' => 19.95
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

    ].each do |path, result|

      it "gets #{path.inspect}" do

        expect(Dense.get(@data, path)).to eq(result)
      end
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

    it 'sets array first' #do
#
#      o = { 'h' => { 'a' => [ 1, 2, 3 ] } }
#      r = Dense.set(o, 'h.a.first', 'one')
#
#      expect(o).to eq({ 'h' => { 'a' => [ "one", 2, 3 ] } })
#      expect(r).to eq('one')
#    end

    it 'sets array last' #do
#
#      o = { 'h' => { 'a' => [ 1, 2, 3 ] } }
#      r = Dense.set(o, 'h.a.last', 'three')
#
#      expect(o).to eq({ 'h' => { 'a' => [ 1, 2, 'three' ] } })
#      expect(r).to eq('three')
#    end

    it 'fails if it cannot set (mismatch)' #do
#
#      c = { 'a' => [] }
#
#      expect {
#        Dense.set(c, 'a.b', 1)
#      }.to raise_error(
#        IndexError, 'xxx'
#      )
#
#      expect(c).to eq({ 'a' => [] })
#    end

    it 'fails if it cannot set (mismatch 2)' #do
#
#      c = { 'a' => {} }
#
#      expect {
#        Dense.set(c, 'a.1', 1)
#      }.to raise_error(
#        IndexError, 'xxx'
#      )
#
#      expect(c).to eq({ 'a' => [] })
#    end

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
end

