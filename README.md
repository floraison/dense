
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

### paths

```ruby
"store.book.1.title"            # the title of the second book in the store
"store.book[1].title"           # the title of the second book in the store
"store.book.1['french title']"  # the french title of the 2nd book
"store.book.1[title,author]"    # the title and the author of the 2nd book
"store.book[1,3].title"         # the titles of the 2nd and 4th books
"store.book[1:8:2].title"       # titles of books at offset 1, 3, 5, 7
"store.book[::3].title"         # titles of books at offset 0, 3, 6, 9, ...
"store.book[:3].title"          # titles of books at offset 0, 1, 2, 3
"store.*.price"                 # the price of everything directly in the store
"store..price"                  # the price of everything in the store
# ...
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

As seen above `Dense.get` might return a single value or an array of values. A "single" path like `"store.book.1.title"` will return a single value, while a "multiple" path like `"store.book.*.title"` or `"store.book[1,2].title"` will return an array of values.


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

When it doesn't find, it raises an instance of `KeyError`:

```ruby
Dense.fetch({}, 'a.0.b')
  # raises
  #   KeyError: Found nothing at "a" ("0.b" remains)
```

It might instead raise an instance of `TypeError` if a non-integer key is requested of an array:

```ruby
Dense.fetch({ 'a' => [] }, 'a.k.b')
  # raises
  #   TypeError: No key "k" for Array at "a"
```

See KeyError and TypeError below for more details.

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
  # => TypeError: No key "b" for Array at "a"


c = { 'a' => {} }
r = Dense.set(c, 'a.1', 1)
c   # => { 'a' => { '1' => 1 } }
r   # => 1

c = {}
Dense.set(c, 'a.0', 1)
  # => KeyError: Found nothing at "a" ("0" remains)
```

Setting at multiple places in one go is possible:
```ruby
c = { 'h' => {} }
Dense.set(c, 'h[k0,k1,k2]', 123)
c
  # => { 'h' => { 'k0' => 123, 'k1' => 123, 'k2' => 123 } }
```


### `Dense.insert(collection, path, value)`

```ruby
c = { 'a' => [ 0, 1, 2, 3 ] }
r = Dense.insert(c, 'b', 1234)
c
  # => { "a" => [ 0, 1, 2, 3 ], "b" => 1234 }

c = { 'a' => [ 0, 1, 2, 3 ] }
r = Dense.insert(c, 'a.1', 'ONE')
c
  # => { "a" => [ 0, "ONE", 1, 2, 3 ] }

c = { 'a' => [ 0, 1, 2, 3 ], 'a1' => [ 0, 1 ] }
r = Dense.insert(c, '.1', 'ONE')
c
  # => { "a" => [ 0, "ONE", 1, 2, 3 ], "a1" => [ 0, "ONE", 1 ] }
```


### `Dense.unset(collection, path)`

Removes an element deep in a collection.
```ruby
c = { 'a' => 1 }
r = Dense.unset(c, 'a')
c   # => {}
r   # => 1

c = { 'h' => { 'i' => 1 } }
r = Dense.unset(c, 'h.i')
c   # => { 'h' => {} }
r   # => 1

c = { 'a' => [ 1, 2, 3 ] }
r = Dense.unset(c, 'a.1')
c   # => { 'a' => [ 1, 3 ] }
r   # => 2

c = { 'h' => { 'a' => [ 1, 2, 3 ] } }
r = Dense.unset(c, 'h.a.first')
c   # => { 'h' => { 'a' => [ 2, 3 ] } }
r   # => 1

c = { 'h' => { 'a' => [ 1, 2, 3 ] } }
r = Dense.unset(c, 'h.a.last')
c   # => { 'h' => { 'a' => [ 1, 2 ] } }
r   # => 3
```

It fails with a `KeyError` or a `TypeError` if it cannot unset.
```ruby
Dense.unset({}, 'a')
  # => KeyError: Found nothing at "a"
Dense.unset([], 'a')
  # => TypeError: No key "a" for Array at root
Dense.unset([], '1')
  # => KeyError: Found nothing at "1"
```

Unsetting multiple values is OK:

```ruby
c = { 'h' => { 'a' => [ 1, 2, 3, 4, 5 ] } }
r = Dense.unset(c, 'h.a[2,3]')
c
  # => { 'h' => { 'a' => [ 1, 2, 5 ] } }
```

### KeyError and TypeError

Dense might raise instances of `KeyError` and `TypeError`. Those instances have extra `#full_path` and `#miss` methods.

```ruby
e =
  begin
    Dense.fetch({}, 'a.b')
  rescue => err
    err
  end
  # => #<KeyError: Found nothing at "a" ("b" remains)>
e.full_path
  # => "a"
e.miss
  # => [false, [], {}, "a", [ "b" ]]
```

The "miss" is an array `[ false, path-to-miss, collection-at-miss, key-at-miss, path-post-miss ]`.


## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

