
module Dense; class << self

  def get(o, path)

    Dense::Path.new(path).walk(o)
  end

  def set(o, path, value)

    path = Dense::Path.new(path)
    key = path.pop

#p path.walk(o)
#p key
#p value
    case c = path.walk(o)
    when Array then array_set(c, key, value)
    when Hash then c[key.to_s] = value
    else fail IndexError.new("Found no collection at #{path.to_s.inspect}")
    end

    value
  end

  def unset(o, path)

    path = Dense::Path.new(path)
    key = path.pop

    case c = path.walk(o)
    when Array then array_unset(c, key)
    when Hash then c.delete(key.to_s)
    else fail IndexError.new("Found no collection at #{path.to_s.inspect}")
    end
  end

  protected

  def array_index(a, k)

    i =
      case k
      when 'first' then 0
      when 'last' then -1
      when Integer then k
      else nil
      end

    fail IndexError.new(
      "Cannot unset index #{k.inspect} of an array"
    ) unless i

    i = a.length + i if i < 0

    fail IndexError.new(
      "Array has length of #{a.length}, index #{k.inspect}"
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
end; end

