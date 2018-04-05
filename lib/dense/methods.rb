
module Dense; class << self

  def get(o, path)

    path = Dense::Path.new(path)
    r = path.gather(o).inject([]) { |a, e| a << e[1][e[3]] if e.first; a }

    path.single? ? r.first : r
  end

  def fetch(o, path, default=::KeyError, &block)

    pa = Dense::Path.new(path)
    r = pa.gather(o).partition(&:first)

    if r[0].empty?

      return pa.narrow(
        r[1].collect { |m| call_default_block(o, path, block, m) }
      ) if block

      return pa.narrow(
        r[1].collect { |m| default }
      ) if default != KeyError

      fail key_error(path, r[1])
    end

    pa.narrow(r[0].collect { |e| e[1][e[3]] })
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

    !! Dense::Path.new(path).gather(o).find { |m| m[0] }
  end

  protected

  def key_error(path, misses)

    miss = misses.first

    path0 = Dense::Path.make(miss[1] + miss[3][0, 1]).to_s.inspect
    path1 = Dense::Path.make(miss[3][1..-1]).to_s.inspect

    msg = "Found nothing at #{path0}"
    msg = "#{msg} (#{path1} remains)" if path1 != '""'

    KeyError.new(msg)
  end

  def call_default_block(o, path, block, miss)

    args = [
      o, path, Dense::Path.make(miss[1]), miss[2], Dense::Path.make(miss[3])
    ][0, block.arity]

    block.call(*args)
  end

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

#  def array_has_key?(a, k)
#
#    i =
#      array_i(k, false)
#    i =
#      if i.nil?
#        -1
#      elsif i < 0
#        a.length + i
#      else
#        i
#      end
#
#    i > -1 && i < a.length
#  end
#
#  def hash_has_key?(h, k)
#
#    return true if k.is_a?(Integer) && h.has_key?(k.to_s)
#    h.has_key?(k)
#  end
end; end # Dense

