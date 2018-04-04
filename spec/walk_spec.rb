
#
# Specifying dense
#
# Sun Aug 20 06:58:44 JST 2017
#

require 'spec_helper'


describe Dense::Path do

  before :all do

    @data0 = # taken from http://goessner.net/articles/JsonPath/
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

    @data1 = { # taken from http://jsonpath.com/
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
        expect(pa.walk(@data0)).to eq(result)
      end
    end

    it 'walks "store..*"' do

      pa = Dense::Path.new('store..*')

      r = pa.walk(@data0)
#pp r

      expect(r).not_to eq(nil)

      expect(r.size).to eq(32)

      expect(r[0]).to eq(@data0['store'])
      expect(r[26]).to eq(19.95)
      expect(r[31]).to eq('t')
    end
  end

  describe '#gather' do

    {

      'store.bicycle.color' => [
        [ true,
          { 'color' => 'red', 'price' => 19.95, '7' => 'seven',
            '8' => %w[ ei gh t ] },
          'color',
          'color' ] ],
      'store.bicycle.price' => [
        [ true,
          { 'color' => 'red', 'price' => 19.95, '7' => 'seven',
            '8' => %w[ ei gh t ] },
          'price',
          'price' ] ],

      'store.book.1.author' => [
        [ true,
          { 'category' => 'fiction', 'author' => 'Evelyn Waugh',
            'title' => 'Sword of Honour', 'price' => 12.99 },
          'author',
          'author' ] ],

      'store.book.*.title' => [
        [ true,
          { 'category' => 'reference', 'author' => 'Nigel Rees',
            'title' => 'Sayings of the Century', 'price' => 8.95 },
          'title',
          'title' ],
        [ true,
          { 'category' => 'fiction', 'author' => 'Evelyn Waugh',
            'title' => 'Sword of Honour', 'price' => 12.99 },
          'title',
          'title' ],
        [ true,
          { 'category' => 'fiction', 'author' => 'Herman Melville',
            'title' => 'Moby Dick', 'isbn' => '0-553-21311-3',
            'price' => 8.99 },
          'title',
          'title' ],
        [ true,
          { 'category' => 'fiction', 'author' => 'J. R. R. Tolkien',
            'title' => 'The Lord of the Rings', 'isbn' => '0-395-19395-8',
            'price' => 22.99 },
          'title',
          'title' ] ],

      'store.book[2:3].author' => [
        [ true,
          { 'category' => 'fiction', 'author' => 'Herman Melville',
            'title' => 'Moby Dick', 'isbn' => '0-553-21311-3',
            'price' => 8.99 },
          'author',
          'author' ],
        [ true,
          { 'category' => 'fiction', 'author' => 'J. R. R. Tolkien',
            'title' => 'The Lord of the Rings', 'isbn' => '0-395-19395-8',
            'price' => 22.99 },
          'author',
          'author' ] ],

      'store.book[::2].author' => [
        [ true,
          { 'category' => 'reference', 'author' => 'Nigel Rees',
            'title' => 'Sayings of the Century', 'price' => 8.95 },
          'author',
          'author' ],
        [ true,
          { 'category' => 'fiction', 'author' => 'Herman Melville',
            'title' => 'Moby Dick', 'isbn' => '0-553-21311-3',
            'price' => 8.99 },
          'author',
          'author' ] ],

      'store.book[1::2].author' => [
        [ true,
          { 'category' => 'fiction',
            'author' => 'Evelyn Waugh',
            'title' => 'Sword of Honour',
            'price' => 12.99 },
          'author',
          'author' ],
        [ true,
          { 'category' => 'fiction',
            'author' => 'J. R. R. Tolkien',
            'title' => 'The Lord of the Rings',
            'isbn' => '0-395-19395-8',
            'price' => 22.99 },
          'author',
          'author' ] ],

      'store.book.-1.title' => [
        [ true,
          { 'category' => 'fiction', 'author' => 'J. R. R. Tolkien',
            'title' => 'The Lord of the Rings', 'isbn' => '0-395-19395-8',
            'price' => 22.99 },
          'title',
          'title' ] ],

      'store.book[-3:-2].title' => [
        [ true,
          { 'category' => 'fiction', 'author' => 'Evelyn Waugh',
            'title' => 'Sword of Honour', 'price' => 12.99 },
          'title',
          'title' ],
        [ true,
          { 'category' => 'fiction', 'author' => 'Herman Melville',
            'title' => 'Moby Dick', 'isbn' => '0-553-21311-3',
            'price' => 8.99 },
          'title',
          'title' ] ],

      'store.book.1.price' => [
        [ true,
          { 'category' => 'fiction', 'author' => 'Evelyn Waugh',
            'title' => 'Sword of Honour', 'price' => 12.99 },
          'price',
          'price' ] ],

      'store.book.1..price' => [
        [ true,
          { 'category' => 'fiction', 'author' => 'Evelyn Waugh',
            'title' => 'Sword of Honour', 'price' => 12.99 },
          'price',
          'price' ] ],

      'store..price' => [
        [ true,
          { 'category' => 'reference', 'author' => 'Nigel Rees',
            'title' => 'Sayings of the Century', 'price' => 8.95 },
          'price',
          'price' ],
        [ true,
          { 'category' => 'fiction', 'author' => 'Evelyn Waugh',
            'title' => 'Sword of Honour', 'price' => 12.99 },
          'price',
          'price' ],
        [ true,
          { 'category' => 'fiction', 'author' => 'Herman Melville',
            'title' => 'Moby Dick', 'isbn' => '0-553-21311-3',
            'price' => 8.99 },
          'price',
          'price' ],
        [ true,
          { 'category' => 'fiction', 'author' => 'J. R. R. Tolkien',
            'title' => 'The Lord of the Rings', 'isbn' => '0-395-19395-8',
            'price' => 22.99 },
          'price',
          'price' ],
        [ true,
          { 'color' => 'red', 'price' => 19.95, '7' => 'seven',
            '8' => %w[ ei gh t ] },
          'price',
          'price' ] ],

#      #'store../^pr/' => [ 8.95, 12.99, 8.99, 22.99, 19.95 ],

      '.book.1' => [
        [ true,
          [ { 'category' => 'reference', 'author' => 'Nigel Rees',
              'title' => 'Sayings of the Century', 'price' => 8.95 },
            { 'category' => 'fiction', 'author' => 'Evelyn Waugh',
              'title' => 'Sword of Honour', 'price' => 12.99 },
            { 'category' => 'fiction', 'author' => 'Herman Melville',
              'title' => 'Moby Dick', 'isbn' => '0-553-21311-3',
              'price' => 8.99 },
            { 'category' => 'fiction', 'author' => 'J. R. R. Tolkien',
              'title' => 'The Lord of the Rings', 'isbn' => '0-395-19395-8',
              'price' => 22.99 } ],
          1,
          1 ] ],

      '.*[0]' => [
        [ true,
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
          [ 0 ] ]
        ],

      'store.book.first.author' => [
        [ true,
          { 'category' => 'reference', 'author' => 'Nigel Rees',
            'title' => 'Sayings of the Century', 'price' => 8.95 },
          'author',
          'author' ] ],
      'store.book.First.author' => [
        [ true,
          { 'category' => 'reference', 'author' => 'Nigel Rees',
            'title' => 'Sayings of the Century', 'price' => 8.95 },
          'author',
          'author' ] ],
      'store.book.last.author' => [
        [ true,
          { 'category' => 'fiction', 'author' => 'J. R. R. Tolkien',
            'title' => 'The Lord of the Rings', 'isbn' => '0-395-19395-8',
            'price' => 22.99 },
          'author',
          'author' ] ],

      'store.bicycle.7' => [
        [ true,
          { 'color' => 'red', 'price' => 19.95, '7' => 'seven',
            '8' => %w[ ei gh t ] },
          7,
          '7' ] ],

      'store.bicycle.8.1' => [
        [ true, %w[ ei gh t ], 1, 1 ] ],

    }.each do |path, result|

      it "gathers leaves for #{path.inspect}" do

        pa = Dense::Path.new(path)

        expect(pa).not_to eq(nil)
#pp pa.gather(@data0)
        expect(pa.gather(@data0)).to eq(result)
      end
    end

    it 'gathers for "store..*"' do

      pa = Dense::Path.new('store..*')

      r = pa.gather(@data0)
#pp r

      expect(r.size).to eq(32)

      expect(r[0]).to eq([ true, @data0['store'], :star, :star ])
      expect(r[31]).to eq([ true, 't', :star, :star ])
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
          [ 'nickName' ] ] ],

      'address.country' => [
        [ false,
          [ 'address' ],
          { 'streetAddress'=>'naist street', 'city'=>'Nara',
            'postalCode'=>'630-0192' },
          [ 'country' ] ] ],

      'phoneNumbers.-3' => [
        [ false,
          [ "phoneNumbers" ],
          [ { "type"=>"iPhone", "number"=>"0123-4567-8888" },
            { "type"=>"home", "number"=>"0123-4567-8910" } ],
          [ -3 ] ] ],

    }.each do |path, result|

      it "gathers false leaves for #{path.inspect}" do

        pa = Dense::Path.new(path)

        expect(pa).not_to eq(nil)
#pp pa.gather(@data1)
        expect(pa.gather(@data1)).to eq(result)
      end
    end
  end
end

