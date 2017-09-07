
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

  protected

  def array_set(a, k, v)

    case k
    when 'first' then a[0] = v
    when 'last' then a[-1] = v
    else a[k] = v
    end
  end
end; end

