
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
end

