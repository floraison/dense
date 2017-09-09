
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

  def array_set(a, k, v)

    case k
    when 'first' then a[0] = v
    when 'last' then a[-1] = v
    when Integer then a[k] = v
    else fail IndexError.new("Cannot set index #{k.inspect} of an array")
    end
  end

  def array_unset(a, k)

    case k
    when 'first' then a.delete_at(0)
    when 'last' then a.delete_at(-1)
    when Integer then a.delete_at(k)
    else fail IndexError.new("Cannot unset index #{k.inspect} of an array")
    end
  end
end; end

