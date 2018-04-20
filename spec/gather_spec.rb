
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

  describe '#gather' do

    {

      'store.bicycle.color' => [
        [ true, [ 'store', 'bicycle' ], BIKE, 'color' ] ],
      'store.bicycle.price' => [
        [ true, [ 'store', 'bicycle' ], BIKE, 'price' ] ],

      'store.book.1.author' => [
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'author' ] ],

      'store.book.*.title' => [
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'title' ],
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'title' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'title' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'title' ] ],

      'store.book[2:3].author' => [
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'author' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'author' ] ],

      'store.book[::2].author' => [
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'author' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'author' ] ],

      'store.book[1::2].author' => [
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'author' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'author' ] ],

      'store.book.-1.title' => [
        [ true, [ 'store', 'book', -1 ], BOOK[-1], 'title' ] ],

      'store.book[-3:-2].title' => [
        [ true, [ 'store', 'book', -3 ], BOOK[-3], 'title' ],
        [ true, [ 'store', 'book', -2 ], BOOK[-2], 'title' ] ],

      'store.book.1.price' => [
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'price' ] ],

      'store.*' => [
        [ true, [ 'store' ], STORE, 'book' ],
        [ true, [ 'store' ], STORE, 'bicycle' ] ],

      'store.book.first.author' => [
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'author' ] ],
      'store.book.First.author' => [
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'author' ] ],
      'store.book.last.author' => [
        [ true, [ 'store', 'book', -1 ], BOOK[-1], 'author' ] ],

      'store.bicycle.7' => [
        [ true, %w[ store bicycle ], BIKE, '7' ] ],

      'store.bicycle.8.1' => [
        [ true, [ 'store', 'bicycle', '8' ], %w[ ei gh t ], 1 ] ],

      'store.book.1..price' => [
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'price' ] ],

      'store..price' => [
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'price' ],
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'price' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'price' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'price' ],
        [ true, [ 'store', 'bicycle' ], BIKE, 'price' ] ],

      'store..*' => [
        [ true, [ 'store' ], STORE, 'book' ],
        [ true, [ 'store', 'book' ], BOOK, 0 ],
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'category' ],
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'author' ],
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'title' ],
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'price' ],
        [ true, [ 'store', 'book' ], BOOK, 1 ],
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'category' ],
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'author' ],
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'title' ],
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'price' ],
        [ true, [ 'store', 'book' ], BOOK, 2 ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'category' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'author' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'title' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'isbn' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'price' ],
        [ true, [ 'store', 'book' ], BOOK, 3 ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'category' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'author' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'title' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'isbn' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'price' ],
        [ true, [ 'store' ], STORE, 'bicycle' ],
        [ true, [ 'store', 'bicycle' ], BIKE, 'color' ],
        [ true, [ 'store', 'bicycle' ], BIKE, 'price' ],
        [ true, [ 'store', 'bicycle' ], BIKE, '7' ],
        [ true, [ 'store', 'bicycle' ], BIKE, '8' ],
        [ true, [ 'store', 'bicycle', '8' ], BIKE['8'], 0 ],
        [ true, [ 'store', 'bicycle', '8' ], BIKE['8'], 1 ],
        [ true, [ 'store', 'bicycle', '8' ], BIKE['8'], 2 ] ],

#      #'store../^pr/' => [ 8.95, 12.99, 8.99, 22.99, 19.95 ],

      '.book.1' => [
        [ true, [ 'store', 'book' ], BOOK, 1 ] ],

      '.0' => [
        [ true, [ 'store', 'book' ], BOOK, 0 ],
        [ true, [ 'store', 'bicycle', '8' ], BIKE['8'], 0 ] ],
      '.[0]' => [
        [ true, [ 'store', 'book' ], BOOK, 0 ],
        [ true, [ 'store', 'bicycle', '8' ], BIKE['8'], 0 ] ],

      '.*[0]' => [
        [ false, [ 'store' ], DATA0['store'], '0' ],
        [ true, [ 'store', 'book' ], BOOK, 0 ],
        [ false, [ 'store', 'book', 0 ], BOOK[0], '0' ],
        [ false, [ 'store', 'book', 0 ], BOOK[0], 'category' ],
        [ false, [ 'store', 'book', 0 ], BOOK[0], 'author' ],
        [ false, [ 'store', 'book', 0 ], BOOK[0], 'title' ],
        [ false, [ 'store', 'book', 0 ], BOOK[0], 'price' ],
        [ false, [ 'store', 'book', 1 ], BOOK[1], '0' ],
        [ false, [ 'store', 'book', 1 ], BOOK[1], 'category' ],
        [ false, [ 'store', 'book', 1 ], BOOK[1], 'author' ],
        [ false, [ 'store', 'book', 1 ], BOOK[1], 'title' ],
        [ false, [ 'store', 'book', 1 ], BOOK[1], 'price' ],
        [ false, [ 'store', 'book', 2 ], BOOK[2], '0' ],
        [ false, [ 'store', 'book', 2 ], BOOK[2], 'category' ],
        [ false, [ 'store', 'book', 2 ], BOOK[2], 'author' ],
        [ false, [ 'store', 'book', 2 ], BOOK[2], 'title' ],
        [ false, [ 'store', 'book', 2 ], BOOK[2], 'isbn' ],
        [ false, [ 'store', 'book', 2 ], BOOK[2], 'price' ],
        [ false, [ 'store', 'book', 3 ], BOOK[3], '0' ],
        [ false, [ 'store', 'book', 3 ], BOOK[3], 'category' ],
        [ false, [ 'store', 'book', 3 ], BOOK[3], 'author' ],
        [ false, [ 'store', 'book', 3 ], BOOK[3], 'title' ],
        [ false, [ 'store', 'book', 3 ], BOOK[3], 'isbn' ],
        [ false, [ 'store', 'book', 3 ], BOOK[3], 'price' ],
        [ false, [ 'store', 'bicycle' ], BIKE, '0' ],
        [ false, [ 'store', 'bicycle', ], BIKE, 'color' ],
        [ false, [ 'store', 'bicycle', ], BIKE, 'price' ],
        [ false, [ 'store', 'bicycle', ], BIKE, '7' ],
        [ true, [ 'store', 'bicycle', '8' ], BIKE['8'], 0 ],
        [ false, [ 'store', 'bicycle', '8' ], BIKE['8'], 1 ],
        [ false, [ 'store', 'bicycle', '8' ], BIKE['8'], 2 ] ],

    }.each do |path, expected|

      def summarize_h2(h2)
        j = h2.to_json.gsub('"', '')
        d = Digest::MD5.hexdigest(j)[0, 5]
        [ h2.class, j[0, 14], j.length, d ].map(&:to_s).join('|')
      end
      def summarize(hits)
        hits.collect { |h| [ h[0], h[1], summarize_h2(h[2]), h[3] ] }
      end

      it "gathers leaves for #{path.inspect}" do

        pa = Dense::Path.new(path)

        expect(pa).not_to eq(nil)

        r = pa.gather(DATA0)

        expect(summarize(r).to_pp).to eq(summarize(expected).to_pp)
        expect(r.to_pp).to eq(expected.to_pp)
        #expect(r).to eq(expected)
      end
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
