
# dense


## dense 1.2.0 not yet released

* Introduce Dense.paths(coll, '..author')
* Stop fooling around and stick to https://semver.org


## dense 1.1.6 released 2018-12-24  (Merry Christmas!)

* Interpret "replies.0_1_2" as `[ "replies", "0_1_2" ]` not `[ "replies", 0 ]`


## dense 1.1.5 released 2018-12-04

* Differentiate KeyError and IndexError upon miss


## dense 1.1.4  released 2018-11-08

* Fix `Dense.fetch({ 'a' => nil }, 'a')`
* Implement Dense.force_set(coll, k, v)


## dense 1.1.3  released 2018-08-13

* Accept '!' in names


## dense 1.1.2  released 2018-07-15

* Accept string and symbol keys in path arrays
* Accept path arrays in Dense::Path.make


## dense 1.1.1  released 2018-06-15

* Accept `[a;b;c]` union keys
* Accept regular expressions for object keys


## dense 1.1.0  released 2018-04-29

* Add Dense.path(path) and Dense.gather(collection, path)
* Use but enhance KeyError and TypeError
* Differentiate between `*` and `.*`
* Complete ework around Path#gather
* Straighten Dense.fetch


## dense 1.0.0  released 2017-09-29

* Accept `owner[age]` (unquoted key name in bracket index)
* Accept '=' and '?' in key names
* Introduce Dense::Path#last
* Introduce Dense::Path indexation and equality
* Introduce Dense::Path #length and #size
* Introduce Dense::Path::NotIndexableError#relabel
* Introduce Dense::Path::NotIndexableError
* Differentiate `Dense.get(col, path)` from `Dense.fetch(col, path[, default])`
* Provide Dense::Path.to_s
* Introduce Dense.has_key?(collection, path)
* Introduce Dense.insert(collection, path, value)
* Accept `.first` and `.last` when indexing arrays
* Introduce Dense.unset(collection, path)
* Introduce Dense.set(collection, path, value)
* Introduce Dense.get(collection, path)


## dense 0.1.0  released 2017-08-06

* initial release

