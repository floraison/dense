
#
# Specifying dense
#
# Sun Aug 20 06:58:44 JST 2017
#

require 'spec_helper'


require 'digest'

def summarize_h2(h2)
  j = h2.to_json.gsub('"', '')
  d = Digest::MD5.hexdigest(j)[0, 5]
  [ h2.class, j[0, 7], j.length, d ].map(&:to_s).join('|')
end
def summarize(hits)
  hits.collect { |h| [ h[0], h[1], summarize_h2(h[2]), h[3], h[4] ] }
end


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

      'store.book[2,3].title' => [
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'title' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'title' ],
        [ false, [ 'store', 'book' ], BOOK, 4, [ 'title' ] ] ],

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
        [ false, [ 'store' ], DATA0['store'], '0', [] ],
        [ true, [ 'store', 'book' ], BOOK, 0 ],
        [ false, [ 'store', 'book', 0 ], BOOK[0], '0', [] ],
        [ false, [ 'store', 'book', 0, 'category' ], BOOK[0]['category'], 0, [] ],
        [ false, [ 'store', 'book', 0, 'author' ], BOOK[0]['author'], 0, [] ],
        [ false, [ 'store', 'book', 0, 'title' ], BOOK[0]['title'], 0, [] ],
        [ false, [ 'store', 'book', 0, 'price' ], BOOK[0]['price'], 0, [] ],
        [ false, [ 'store', 'book', 1 ], BOOK[1], '0', [] ],
        [ false, [ 'store', 'book', 1, 'category' ], BOOK[1]['category'], 0, [] ],
        [ false, [ 'store', 'book', 1, 'author' ], BOOK[1]['author'], 0, [] ],
        [ false, [ 'store', 'book', 1, 'title' ], BOOK[1]['title'], 0, [] ],
        [ false, [ 'store', 'book', 1, 'price' ], BOOK[1]['price'], 0, [] ],
        [ false, [ 'store', 'book', 2 ], BOOK[2], '0', [] ],
        [ false, [ 'store', 'book', 2, 'category' ], BOOK[2]['category'], 0, [] ],
        [ false, [ 'store', 'book', 2, 'author' ], BOOK[2]['author'], 0, [] ],
        [ false, [ 'store', 'book', 2, 'title' ], BOOK[2]['title'], 0, [] ],
        [ false, [ 'store', 'book', 2, 'isbn' ], BOOK[2]['isbn'], 0, [] ],
        [ false, [ 'store', 'book', 2, 'price' ], BOOK[2]['price'], 0, [] ],
        [ false, [ 'store', 'book', 3 ], BOOK[3], '0', [] ],
        [ false, [ 'store', 'book', 3, 'category' ], BOOK[3]['category'], 0, [] ],
        [ false, [ 'store', 'book', 3, 'author' ], BOOK[3]['author'], 0, [] ],
        [ false, [ 'store', 'book', 3, 'title' ], BOOK[3]['title'], 0, [] ],
        [ false, [ 'store', 'book', 3, 'isbn' ], BOOK[3]['isbn'], 0, [] ],
        [ false, [ 'store', 'book', 3, 'price' ], BOOK[3]['price'], 0, [] ],
        [ false, [ 'store', 'bicycle' ], BIKE, '0', [] ],
        [ false, [ 'store', 'bicycle', 'color' ], BIKE['color'], 0, [] ],
        [ false, [ 'store', 'bicycle', 'price' ], BIKE['price'], 0, [] ],
        [ false, [ 'store', 'bicycle', '7' ], BIKE['7'], 0, [] ],
        [ true, [ 'store', 'bicycle', '8' ], BIKE['8'], 0 ],
        [ false, [ 'store', 'bicycle', '8', 0 ], BIKE['8'][0], 0, [] ],
        [ false, [ 'store', 'bicycle', '8', 1 ], BIKE['8'][1], 0, [] ],
        [ false, [ 'store', 'bicycle', '8', 2 ], BIKE['8'][2], 0, [] ] ],

      'store.book.*./^ti/' => [
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'title' ],
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'title' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'title' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'title' ] ],
      'store.book.*[/(title|author)/,isbn]' => [
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'author' ],
        [ true, [ 'store', 'book', 0 ], BOOK[0], 'title' ],
        [ false, [ 'store', 'book', 0 ], BOOK[0], 'isbn', [] ],
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'author' ],
        [ true, [ 'store', 'book', 1 ], BOOK[1], 'title' ],
        [ false, [ 'store', 'book', 1 ], BOOK[1], 'isbn', [] ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'author' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'title' ],
        [ true, [ 'store', 'book', 2 ], BOOK[2], 'isbn' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'author' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'title' ],
        [ true, [ 'store', 'book', 3 ], BOOK[3], 'isbn' ] ],

    }.each do |path, expected|

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

      [ 'nickName', DATA1 ] => [
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
          'nickName',
          [] ] ],

      [ 'address.country', DATA1 ] => [
        [ false,
          [ 'address' ],
          { 'streetAddress'=>'naist street', 'city'=>'Nara',
            'postalCode'=>'630-0192' },
          'country',
          [] ] ],

      [ 'phoneNumbers.-3', DATA1 ] => [
        [ false,
          [ "phoneNumbers" ],
          [ { "type"=>"iPhone", "number"=>"0123-4567-8888" },
            { "type"=>"home", "number"=>"0123-4567-8910" } ],
          -3,
          [] ] ],

      [ 'h.a[2:4]', { 'h' => { 'a' => [ 1, 2, 3, 4, 5, 'six' ] } } ] => [
        [ true, [ 'h', 'a' ], [ 1, 2, 3, 4, 5, 'six' ], 2 ],
        [ true, [ 'h', 'a' ], [ 1, 2, 3, 4, 5, 'six' ], 3 ],
        [ true, [ 'h', 'a' ], [ 1, 2, 3, 4, 5, 'six' ], 4 ] ],

      [ 'h[i]', { 'h' => { 'i' => 1, 'j' => 2, 'k' => 3 } } ] => [
        [ true, [ 'h' ], { 'i' => 1, 'j' => 2, 'k' => 3 }, 'i' ] ],

      [ 'h["i"]', { 'h' => { 'i' => 1, 'j' => 2, 'k' => 3 } } ] => [
        [ true, [ 'h' ], { 'i' => 1, 'j' => 2, 'k' => 3 }, 'i' ] ],

      [ 'h["i","k"]', { 'h' => { 'i' => 1, 'j' => 2, 'k' => 3 } } ] => [
        [ true, [ 'h' ], { 'i' => 1, 'j' => 2, 'k' => 3 }, 'i' ],
        [ true, [ 'h' ], { 'i' => 1, 'j' => 2, 'k' => 3 }, 'k' ] ],

      [ 'h[/^(i|k)$/]', { 'h' => { 'i' => 1, 'j' => 2, 'k' => 3 } } ] => [
        [ true, [ 'h' ], { 'i' => 1, 'j' => 2, 'k' => 3 }, 'i' ],
        [ true, [ 'h' ], { 'i' => 1, 'j' => 2, 'k' => 3 }, 'k' ] ],
      [ 'h[/^[^jk]$/]', { 'h' => { 'i' => 1, 'j' => 2, 'k' => 3 } } ] => [
        [ true, [ 'h' ], { 'i' => 1, 'j' => 2, 'k' => 3 }, 'i' ] ],

      [ 'a[1;2]', { 'a' => %w[ A B C D ] } ] => [
        [ true, [ 'a' ], %w[ A B C D ], 1 ],
        [ true, [ 'a' ], %w[ A B C D ], 2 ] ],
      [ 'a[1,2]', { 'a' => %w[ A B C D ] } ] => [
        [ true, [ 'a' ], %w[ A B C D ], 1 ],
        [ true, [ 'a' ], %w[ A B C D ], 2 ] ],

      [ 'a', {} ] => [
        [ false, [], {}, 'a', [] ] ],
      [ 'a', [] ] => [
        [ false, [], [], 'a', [] ] ],
      [ 'a.b', { 'a' => {} } ] => [
        [ false, [ 'a' ], {}, 'b', [] ] ],
      [ 'a.b', { 'a' => [] } ] => [
        [ false, [ 'a' ], [], 'b', [] ] ],

    }.each do |(path, data), expected|

      it "gathers leaves for #{path.inspect}" do

        pa = Dense::Path.new(path)

        expect(pa).not_to eq(nil)

        r = pa.gather(data)

        expect(summarize(r).to_pp).to eq(summarize(expected).to_pp)
        expect(r.to_pp).to eq(expected.to_pp)
        #expect(r).to eq(expected)
      end
    end

    it 'gathers for nil values as well (in objects)' do

      pa = Dense::Path.new('a')

      r = pa.gather({ 'a' => nil })

      expect(
        r
      ).to eq([
        [ true, [], { 'a' => nil }, 'a' ]
      ])
    end

    it 'gathers (deep) for nil values as well (in objects)' do

      pa = Dense::Path.new('a.b')

      r = pa.gather({ 'a' => { 'b' => nil } })

      expect(
        r
      ).to eq([
        [ true, [ 'a' ], { 'b' => nil }, 'b' ]
      ])
    end

    it 'gathers for nil values as well (in arrays)' do

      pa = Dense::Path.new('2')

      r = pa.gather([ nil, nil, nil ])

      expect(
        r
      ).to eq([
        [ true, [], [ nil, nil, nil ], 2 ]
      ])
    end

    it 'gathers (deep) for nil values as well (in arrays)' do

      pa = Dense::Path.new('a.2')

      r = pa.gather({ 'a' => [ nil, nil, nil ] })

      expect(
        r
      ).to eq([
        [ true, [ 'a' ], [ nil, nil, nil ], 2 ]
      ])
    end
  end
end

