
#
# Specifying dense
#
# Sun Aug 20 06:58:44 JST 2017
#

require 'spec_helper'

DATA0 = # taken from http://goessner.net/articles/JsonPath/
  { 'store' => {
      'book' => [
        { 'category' => 'reference',
          'author' => 'Nigel Rees',
          'title' => 'Sayings of the Century',
          'price' => 8.95 },
        { 'category' => 'fiction',
          'author' => 'Evelyn Waugh',
          'title' => 'Sword of Honour',
          'price' => 12.99 },
        { 'category' => 'fiction',
          'author' => 'Herman Melville',
          'title' => 'Moby Dick',
          'isbn' => '0-553-21311-3',
          'price' => 8.99 },
        { 'category' => 'fiction',
          'author' => 'J. R. R. Tolkien',
          'title' => 'The Lord of the Rings',
          'isbn' => '0-395-19395-8',
          'price' => 22.99 } ],
      'bicycle' => {
        'color' => 'red',
        'price' => 19.95,
        '7' => 'seven',
        '8' => [ 'ei', 'gh', 't' ] } } }
STORE = DATA0['store']
BOOK = STORE['book']
BIKE = STORE['bicycle']

DATA1 = { # taken from http://jsonpath.com/
  'firstName' => 'John',
  'lastName' => 'doe',
  'age' => 26,
  'address' => {
    'streetAddress' => 'naist street',
    'city' => 'Nara',
    'postalCode' => '630-0192' },
  'phoneNumbers' => [
    { 'type' => 'iPhone', 'number' => '0123-4567-8888' },
    { 'type' => 'home', 'number' => '0123-4567-8910' } ] }


describe Dense::Path do

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
          'price' => 8.95 },
        'ei' ],
      '.*[-1]' => [
        { 'category' => 'fiction',
          'author' => 'J. R. R. Tolkien',
          'title' => 'The Lord of the Rings',
          'isbn' => '0-395-19395-8',
          'price' => 22.99 },
        't' ],

      'store.book.first.author' => 'Nigel Rees',
      'store.book.First.author' => 'Nigel Rees',
      'store.book.last.author' => 'J. R. R. Tolkien',

      'store.bicycle.7' => 'seven',
      'store.bicycle.8.1' => 'gh',

    }.each do |path, result|

      it "walks #{path.inspect}" do

        pa = Dense::Path.new(path)

        expect(pa).not_to eq(nil)
        expect(pa.walk(DATA0)).to eq(result)
      end
    end

    it 'walks "store..*"' do

      pa = Dense::Path.new('store..*')

      r = pa.walk(DATA0)
#pp r

      expect(r).not_to eq(nil)

      expect(r.size).to eq(32)

      expect(r[0]).to eq(DATA0['store'])
      expect(r[26]).to eq(19.95)
      expect(r[31]).to eq('t')
    end
  end

  describe '#gather' do

    {

      'store.bicycle.color' => [
        [ true, [ 'store', 'bicycle' ], BIKE, 'color', 'color' ] ],
      'store.bicycle.price' => [
        [ true, [ 'store', 'bicycle' ], BIKE, 'price', 'price' ] ],

      'store.book.1.author' => [
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'author', 'author' ] ],

      'store.book.*.title' => [
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'title', 'title' ],
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'title', 'title' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'title', 'title' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'title', 'title' ] ],

      'store.book[2:3].author' => [
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'author', 'author' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'author', 'author' ] ],

      'store.book[::2].author' => [
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'author', 'author' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'author', 'author' ] ],

      'store.book[1::2].author' => [
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'author', 'author' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'author', 'author' ] ],

      'store.book.-1.title' => [
        [ true, [ 'store', 'book', -1 ], BOOK[-1], 'title', 'title' ] ],

      'store.book[-3:-2].title' => [
        [ true, [ 'store', 'book', -3 ], BOOK[-3], 'title', 'title' ],
        [ true, [ 'store', 'book', -2 ], BOOK[-2], 'title', 'title' ] ],

      'store.book.1.price' => [
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'price', 'price' ] ],

      'store.*' => [
        [ true, [ 'store' ], STORE, 'book', 'book' ],
        [ true, [ 'store' ], STORE, 'bicycle', 'bicycle' ] ],

      'store.book.first.author' => [
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'author', 'author' ] ],
      'store.book.First.author' => [
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'author', 'author' ] ],
      'store.book.last.author' => [
        [ true, [ 'store', 'book', -1 ], BOOK[-1], 'author', 'author' ] ],

      'store.bicycle.7' => [
        [ true, %w[ store bicycle ], BIKE, '7', '7' ] ],

      'store.bicycle.8.1' => [
        [ true, [ 'store', 'bicycle', '8' ], %w[ ei gh t ], 1, 1 ] ],

      'store.book.1..price' => [
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'price', 'price' ] ],

      'store..price' => [
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'price', 'price' ],
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'price', 'price' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'price', 'price' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'price', 'price' ],
        [ true, [ 'store', 'bicycle' ], BIKE, 'price', 'price' ] ],

#      #'store../^pr/' => [ 8.95, 12.99, 8.99, 22.99, 19.95 ],

      '.book.1' => [
        [ true, [ 'store', 'book' ], BOOK, 1, 1 ] ],

      '.*[0]' => [
        [ true,
          [ :dot, :star ],
          [ { 'category' => 'reference',
              'author' => 'Nigel Rees',
              'title' => 'Sayings of the Century',
              'price' => 8.95},
            { 'category' => 'fiction',
              'author' => 'Evelyn Waugh',
              'title' => 'Sword of Honour',
              'price' => 12.99},
            { 'category' => 'fiction',
              'author' => 'Herman Melville',
              'title' => 'Moby Dick',
              'isbn' => '0-553-21311-3',
              'price' => 8.99},
            { 'category' => 'fiction',
              'author' => 'J. R. R. Tolkien',
              'title' => 'The Lord of the Rings',
              'isbn' => '0-395-19395-8',
              'price' => 22.99}],
          0,
          0 ],
        [ false,
          [ :dot, :star ],
          { 'color' => 'red',
            'price' => 19.95,
            '7' => 'seven',
            '8' => [ 'ei', 'gh', 't' ] },
          [ 0 ], '0' ]
        ],

    }.each do |path, result|

      it "gathers leaves for #{path.inspect}" do

        pa = Dense::Path.new(path)

        expect(pa).not_to eq(nil)
        r = pa.gather(DATA0)
pp r
        expect(r).to eq(result)
      end
    end

    it 'gathers for "store..*"' do

      pa = Dense::Path.new('store..*')

      r = pa.gather(DATA0)
#pp r

      expect(r.size).to eq(32)

      expect(
        r[0]
      ).to eq(
        [ true, [ 'store', :dot ], DATA0['store'], :star, :star ]
      )
      expect(
        r[31]
      ).to eq(
        [ true, [ 'store', :dot ], 't', :star, :star ]
      )
    end

    {

      'nickName' => [
        [ false,
          [],
          { 'firstName'=>'John',
            'lastName'=>'doe',
            'age'=>26,
            'address'=>
              { 'streetAddress'=>'naist street', 'city'=>'Nara',
                'postalCode'=>'630-0192' },
            'phoneNumbers'=> [
              { 'type'=>'iPhone', 'number'=>'0123-4567-8888' },
              { 'type'=>'home', 'number'=>'0123-4567-8910' } ] },
          [ 'nickName' ], 'nickName' ] ],

      'address.country' => [
        [ false,
          [ 'address' ],
          { 'streetAddress'=>'naist street', 'city'=>'Nara',
            'postalCode'=>'630-0192' },
          [ 'country' ], 'country' ] ],

      'phoneNumbers.-3' => [
        [ false,
          [ "phoneNumbers" ],
          [ { "type"=>"iPhone", "number"=>"0123-4567-8888" },
            { "type"=>"home", "number"=>"0123-4567-8910" } ],
          [ -3 ], -3 ] ],

    }.each do |path, result|

      it "gathers false leaves for #{path.inspect}" do

        pa = Dense::Path.new(path)

        expect(pa).not_to eq(nil)
#pp pa.gather(DATA1)
        expect(pa.gather(DATA1)).to eq(result)
      end
    end

    it 'gathers for h.a[2:4]' do

      data = { 'h' => { 'a' => [ 1, 2, 3, 4, 5, 'six' ] } }
      pa = Dense::Path.new('h.a[2:4]')
      r = pa.gather(data)

      expect(r).to eq([
        [ true, [ 'h', 'a' ], [ 1, 2, 3, 4, 5, 'six' ], 2, 2, :r ],
        [ true, [ 'h', 'a' ], [ 1, 2, 3, 4, 5, 'six' ], 3, 3, :r ],
        [ true, [ 'h', 'a' ], [ 1, 2, 3, 4, 5, 'six' ], 4, 4, :r ]
      ])
    end
  end
end

