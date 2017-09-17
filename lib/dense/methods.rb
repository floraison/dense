
module Dense; class << self

  def get(o, path)

    Dense::Path.new(path).walk(o)
  end

  def set(o, path, value)

    path = Dense::Path.new(path)
    key = path.pop

    case c = path.walk(o)
    when Array then array_set(c, key, value)
    when Hash then c[key.to_s] = value
    else fail KeyError.new("Found no collection at #{path.to_s.inspect}")
    end

    value
  end

  def unset(o, path)

    path = Dense::Path.new(path)
    key = path.pop

    case c = path.walk(o)
    when Array then array_unset(c, key)
    when Hash then hash_unset(c, key.to_s)
    else fail KeyError.new("Found no collection at #{path.to_s.inspect}")
    end
  end

  def insert(o, path, value)

    path = Dense::Path.new(path)
    key = path.pop

    case c = path.walk(o)
    when Array then array_insert(c, key, value)
    when Hash then c[key.to_s] = value
    else fail KeyError.new("Found no collection at #{path.to_s.inspect}")
    end

    value
  end

  def has_key?(o, path)

    path = Dense::Path.new(path)
    key = path.pop

    case c = path.walk(o)
    when Array then array_has_key?(c, key)
    when Hash then hash_has_key?(c, key)
    else fail IndexError.new("Found no collection at #{path.to_s.inspect}")
    end
  end

  protected

  def array_i(k, may_fail=true)

    case k
    when 'first' then 0
    when 'last' then -1
    when Integer then k
    else
      may_fail ?
        fail(IndexError.new("Cannot index array at #{k.inspect}")) :
        nil
    end
  end

  def array_index(a, k)

    i = array_i(k)
    i = a.length + i if i < 0

    fail IndexError.new(
      "Array has length of #{a.length}, index is at #{k.inspect}"
    ) if i < 0 || i >= a.length

    i
  end

  def array_set(a, k, v)

    i = array_index(a, k)

    a[i] = v
  end

  def array_unset(a, k)

    i = array_index(a, k)

    a.delete_at(i)
  end

  def hash_unset(h, k)

    fail KeyError.new("No key #{k.inspect} for hash") unless h.has_key?(k)

    h.delete(k)
  end

  def array_insert(a, k, v)

    i = array_i(k)

    a.insert(i, v)
  end

  def array_has_key?(a, k)

    i =
      array_i(k, false)
    i =
      if i.nil?
        -1
      elsif i < 0
        a.length + i
      else
        i
      end

    i > -1 && i < a.length
  end

  def hash_has_key?(h, k)

    return true if k.is_a?(Integer) && h.has_key?(k.to_s)
    h.has_key?(k)
  end
end; end

