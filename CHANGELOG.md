
# dense


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

