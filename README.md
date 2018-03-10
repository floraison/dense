
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

When `Dense.get(collection, path)` doesn't find, it returns `nil`.


### `Dense.has_key?(collection, path)`

```ruby
Dense.has_key?(data, 'store.book.1.title')
  # => true
Dense.has_key?(data, 'store.book.1["social security number"]')
  # => false
```


### `Dense.fetch(collection, path)`

`Dense.fetch` is modelled after `Hash.fetch`.

```ruby
Dense.fetch(data, 'store.book.1.title')
  # => 'Sword of Honour'

Dense.fetch(data, 'store.book.*.title')
  # => [ 'Sayings of the Century', 'Sword of Honour', 'Moby Dick',
  #      'The Lord of the Rings' ]

Dense.fetch(data, 'store.bicycle.7')
  # => 'seven'

Dense.fetch(data, 'store.bicycle[7]')
  # => 'seven'
```

When it doesn't find, it raises an instance of `Dense::Path::NotIndexableError`.

```ruby
Dense.fetch(data, 'a.0.b')
  # raises
  #   Dense::Path::NotIndexableError
  #   'Found nothing at "a" ("0.b" remains)'
```

`Dense.fetch(collection, path)` raises when it doesn't find, while `Dense.get(collection, path)` returns `nil`.


### `Dense.fetch(collection, path, default)`

`Dense.fetch` is modelled after `Hash.fetch` so it features a `default` optional argument.

If `fetch` doesn't find, it will return the provided default value.

```ruby
Dense.fetch(data, 'store.book.1.title', -1)
  # => "Sword of Honour" (found)
Dense.fetch(data, 'a.0.b', -1)
  # => -1
Dense.fetch(data, 'store.nada', 'x')
  # => "x"
Dense.fetch(data, 'store.bicycle.seven', false)
  # => false
```


### `Dense.fetch(collection, path) { block }`

`Dense.fetch` is modelled after `Hash.fetch` so it features a 'default' optional block.

```ruby
Dense.fetch(data, 'store.book.1.title') do |coll, path|
  "len:#{coll.length},path:#{path}"
end
  # => "Sword of Honour" (found)

Dense.fetch(@data, 'store.bicycle.otto') do |coll, path|
  "len:#{coll.length},path:#{path}"
end
  # => "len:18,path:store.bicycle.otto" (not found)

not_found = lambda { |coll, path| "not found!" }
  #
Dense.fetch(@data, 'store.bicycle.otto', not_found)
  # => "not found!"
Dense.fetch(@data, 'store.bicycle.sept', not_found)
  # => "not found!"
```


### `Dense.set(collection, path, value)`

Sets a value "deep" in a collection. Returns the value if successful.

```ruby
c = {}
r = Dense.set(c, 'a', 1)
c   # => { 'a' => 1 }
r   # => 1

c = { 'h' => {} }
r = Dense.set(c, 'h.i', 1)
c   # => { 'h' => { 'i' => 1 } }
r   # => 1

c = { 'a' => [ 1, 2, 3 ] }
r = Dense.set(c, 'a.1', 1)
c   # => { 'a' => [ 1, 1, 3 ] }
r   # => 1

c = { 'h' => { 'a' => [ 1, 2, 3 ] } }
r = Dense.set(c, 'h.a.first', 'one')
c   # => { 'h' => { 'a' => [ "one", 2, 3 ] } }
r   # => 'one'

c = { 'h' => { 'a' => [ 1, 2, 3 ] } }
r = Dense.set(c, 'h.a.last', 'three')
c   # => { 'h' => { 'a' => [ 1, 2, 'three' ] } }
r   # => 'three'

c = { 'a' => [] }
Dense.set(c, 'a.b', 1)
  # => IndexError 'Cannot index array at "b"'

c = { 'a' => {} }
r = Dense.set(c, 'a.1', 1)
c   # => { 'a' => { '1' => 1 } }
r   # => 1

c = {}
Dense.set(c, 'a.0', 1)
  # => Dense::Path::NotIndexableError 'Found nothing at "a"'
```


### `Dense.insert(collection, path, value)`

TODO document


## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

