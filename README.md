
# dense

[![Build Status](https://secure.travis-ci.org/floraison/dense.svg)](http://travis-ci.org/floraison/dense)
[![Gem Version](https://badge.fury.io/rb/dense.svg)](http://badge.fury.io/rb/dense)

Fetching deep in a dense structure. A kind of bastard of [JSONPath](http://goessner.net/articles/JsonPath/).

## usage

Let
```ruby
  data = # taken from http://goessner.net/articles/JsonPath/
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
```

### `Dense.get(collection, path)`

```ruby
Dense.get(data, 'store.book.1.title')
  # => "Sword of Honour"

Dense.get(data, 'store.book.*.title')
  # => [
  #  'Sayings of the Century',
  #  'Sword of Honour',
  #  'Moby Dick',
  #  'The Lord of the Rings' ]

Dense.get(data, 'store.bicycle.7')
  # => "seven"
```

### `Dense.has_key?(collection, path)`

```ruby
Dense.has_key?(data, 'store.book.1.title')
  # => true
Dense.has_key?(data, 'store.book.1["social security number"]')
  # => false
```

### `Dense.fetch(collection, path)`

TODO document

### `Dense.fetch(collection, path, default)`

TODO document

### `Dense.fetch(collection, path) { block }`

TODO document

### `Dense.set(collection, path, value)`

TODO document

### `Dense.insert(collection, path, value)`

TODO document


## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

