
module Dense; class << self

  def get(o, path)

    #Dense::Path.new(path).walk(o) { nil }

    pa = Dense::Path.new(path)
    r = pa.gather(o).inject([]) { |a, m| a << m[1][m[3]] if m[0]; a }

    pa.single? ? r.first : r
  end

  def fetch(o, path, default=IndexError, &block)

    Dense::Path.new(path).walk(o, default, &block)
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
    when Hash then hash_unset(c, key)
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

  def array_r(k)

    case k
    when 'first' then { start: 0, end: 0, step: 1 }
    when 'last' then { start: -1, end: -1, step: 1 }
    when Integer then { start: k, end: k, step: 1 }
    when Hash then k
    else fail(IndexError.new("Cannot index array at #{k.inspect}"))
    end
  end

  def array_indexes(a, k)

    r = array_r(k)
    r = (r[:start]..r[:end]).step(r[:step] || 1)

    is = []
    r.each { |i| is << i if i < a.length }

    fail IndexError.new(
      "Array has length of #{a.length}, index is at #{r.to_a.last}"
    ) if is.empty?

    is.reverse
  end

  def array_set(a, k, v)

    array_indexes(a, k)
      .each { |i| a[i] = v }

    v
  end

  def array_unset(a, k)

    r = array_indexes(a, k)
      .collect { |i| a.delete_at(i) }
      .reverse

    k.is_a?(Hash) ? r : r.first
  end

  def hash_unset(h, k)

    r = Array(k)
      .collect { |kk|
        fail KeyError.new("No key #{kk.inspect} for hash") unless h.has_key?(kk)
        h.delete(kk) }

    k.is_a?(Array) ? r : r.first
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
end; end # Dense

