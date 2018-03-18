
#
# Specifying dense
#
# Sun Aug 20 06:58:44 JST 2017
#

require 'spec_helper'


describe Dense::Path do

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

  describe '#walk' do

    {

      'store.bicycle.color' => 'red',
      'store.bicycle.price' => 19.95,

      'store.book.1.author' => 'Evelyn Waugh',
      'store.book[2].author' => 'Herman Melville',

      'store.book.*.title' => [
        'Sayings of the Century', 'Sword of Honour', 'Moby Dick',
        'The Lord of the Rings' ],
      'store.book[*].author' => [
        'Nigel Rees', 'Evelyn Waugh', 'Herman Melville', 'J. R. R. Tolkien' ],

      'store.book[2:3].author' => [ 'Herman Melville', 'J. R. R. Tolkien' ],
      'store.book[::2].author' => [ 'Nigel Rees', 'Herman Melville' ],
      'store.book[1::2].author' => [ 'Evelyn Waugh', 'J. R. R. Tolkien' ],

      'store.book.-1.title' => 'The Lord of the Rings',
      'store.book[-1].title' => 'The Lord of the Rings',
      'store.book[-3:-2].title' => [ 'Sword of Honour', 'Moby Dick' ],

      'store..price' => [ 8.95, 12.99, 8.99, 22.99, 19.95 ],
      #'store../^pr/' => [ 8.95, 12.99, 8.99, 22.99, 19.95 ],

      '.book.1' => [
        { 'category' => 'fiction',
          'author' => 'Evelyn Waugh',
          'title' => 'Sword of Honour',
          'price' => 12.99 } ],
      '.*[0]' => [
        { 'category' => 'reference',
          'author' => 'Nigel Rees',
          'title' => 'Sayings of the Century',
          'price' => 8.95 } ],
      '.*[-1]' => [
        { 'category' => 'fiction',
          'author' => 'J. R. R. Tolkien',
          'title' => 'The Lord of the Rings',
          'isbn' => '0-395-19395-8',
          'price' => 22.99 } ],

      'store.book.first.author' => 'Nigel Rees',
      'store.book.First.author' => 'Nigel Rees',
      'store.book.last.author' => 'J. R. R. Tolkien',

      'store.bicycle.7' => 'seven'

    }.each do |path, result|

      it "walks #{path.inspect}" do

        pa = Dense::Path.new(path)

        expect(pa).not_to eq(nil)
        expect(pa.walk(@data)).to eq(result)
      end
    end

    it 'walks "store..*"' do

      pa = Dense::Path.new('store..*')

      r = pa.walk(@data)
#pp r

      expect(r).not_to eq(nil)

      expect(r.size).to eq(28)

      expect(r[0]).to eq(@data['store'])
      expect(r[26]).to eq(19.95)
    end
  end

  describe '#gather' do

    {

      'store.bicycle.color' => [
        [ { 'color' => 'red', 'price' => 19.95, '7' => 'seven' },
          'color' ] ],
      'store.bicycle.price' => [
        [ { 'color' => 'red', 'price' => 19.95, '7' => 'seven' },
          'price' ] ],

      'store.book.1.author' => [
        [ { 'category' => 'fiction', 'author' => 'Evelyn Waugh',
            'title' => 'Sword of Honour', 'price' => 12.99 },
          'author' ] ],

      'store.book.*.title' => [
        [ { 'category' => 'reference', 'author' => 'Nigel Rees',
            'title' => 'Sayings of the Century', 'price' => 8.95 },
          'title' ],
        [ { 'category' => 'fiction', 'author' => 'Evelyn Waugh',
            'title' => 'Sword of Honour', 'price' => 12.99 },
          'title' ],
        [ { 'category' => 'fiction', 'author' => 'Herman Melville',
            'title' => 'Moby Dick', 'isbn' => '0-553-21311-3',
            'price' => 8.99 },
          'title' ],
        [ { 'category' => 'fiction', 'author' => 'J. R. R. Tolkien',
            'title' => 'The Lord of the Rings', 'isbn' => '0-395-19395-8',
            'price' => 22.99 },
          'title' ] ],

      'store.book[2:3].author' => [
        [ { 'category' => 'fiction', 'author' => 'Herman Melville',
            'title' => 'Moby Dick', 'isbn' => '0-553-21311-3',
            'price' => 8.99 },
          'author' ],
        [ { 'category' => 'fiction', 'author' => 'J. R. R. Tolkien',
            'title' => 'The Lord of the Rings', 'isbn' => '0-395-19395-8',
            'price' => 22.99 },
          'author' ] ],

      'store.book[::2].author' => [
        [ { 'category' => 'reference', 'author' => 'Nigel Rees',
            'title' => 'Sayings of the Century', 'price' => 8.95 },
          'author' ],
        [ { 'category' => 'fiction', 'author' => 'Herman Melville',
            'title' => 'Moby Dick', 'isbn' => '0-553-21311-3',
            'price' => 8.99 },
          'author' ] ],

#      'store.book[1::2].author' => [ 'Evelyn Waugh', 'J. R. R. Tolkien' ],

      'store.book.-1.title' => [
        [ { 'category' => 'fiction', 'author' => 'J. R. R. Tolkien',
            'title' => 'The Lord of the Rings', 'isbn' => '0-395-19395-8',
            'price' => 22.99 },
          'title' ] ],

      'store.book[-3:-2].title' => [
        [ { 'category' => 'fiction', 'author' => 'Evelyn Waugh',
            'title' => 'Sword of Honour', 'price' => 12.99 },
          'title' ],
        [ { 'category' => 'fiction', 'author' => 'Herman Melville',
            'title' => 'Moby Dick', 'isbn' => '0-553-21311-3',
            'price' => 8.99 },
          'title' ] ],

      'store..price' => [
        [ { 'category' => 'reference', 'author' => 'Nigel Rees',
            'title' => 'Sayings of the Century', 'price' => 8.95 },
          'price' ],
        [ { 'category' => 'fiction', 'author' => 'Evelyn Waugh',
            'title' => 'Sword of Honour', 'price' => 12.99 },
          'price' ],
        [ { 'category' => 'fiction', 'author' => 'Herman Melville',
            'title' => 'Moby Dick', 'isbn' => '0-553-21311-3',
            'price' => 8.99 },
          'price' ],
        [ { 'category' => 'fiction', 'author' => 'J. R. R. Tolkien',
            'title' => 'The Lord of the Rings', 'isbn' => '0-395-19395-8',
            'price' => 22.99 },
          'price' ],
        [ { 'color' => 'red', 'price' => 19.95, '7' => 'seven' },
          'price' ] ],

#      #'store../^pr/' => [ 8.95, 12.99, 8.99, 22.99, 19.95 ],

      '.book.1' => [
        [ [ { 'category' => 'reference', 'author' => 'Nigel Rees',
              'title' => 'Sayings of the Century', 'price' => 8.95
            },
            { 'category' => 'fiction', 'author' => 'Evelyn Waugh',
              'title' => 'Sword of Honour', 'price' => 12.99
            },
            { 'category' => 'fiction', 'author' => 'Herman Melville',
              'title' => 'Moby Dick', 'isbn' => '0-553-21311-3', 'price' => 8.99
            },
            { 'category' => 'fiction', 'author' => 'J. R. R. Tolkien',
              'title' => 'The Lord of the Rings', 'isbn' => '0-395-19395-8',
              'price' => 22.99
            } ],
        1 ] ],

#      '.*[0]' => [
#        { 'category' => 'reference',
#          'author' => 'Nigel Rees',
#          'title' => 'Sayings of the Century',
#          'price' => 8.95 } ],
#
#      'store.book.first.author' => 'Nigel Rees',
#      'store.book.First.author' => 'Nigel Rees',
#      'store.book.last.author' => 'J. R. R. Tolkien',
#
#      'store.bicycle.7' => 'seven'

    }.each do |path, result|

      it "gathers leaves for #{path.inspect}" do

        pa = Dense::Path.new(path)

        expect(pa).not_to eq(nil)
        expect(pa.gather(@data)).to eq(result)
      end
    end
  end
end

