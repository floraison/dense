
class Dense::Path

  attr_reader :original

  def initialize(s)

    @original = s

    fail ArgumentError.new(
      "Argument is a #{s.class}, not a String"
    ) unless s.is_a?(String)

    s = ".#{s}" \
      unless s[0, 1] == '[' || s[0, 2] == '.['

#Raabro.pp(Parser.parse(s, debug: 3), colors: true)
    @path = Parser.parse(s)

#Raabro.pp(Parser.parse(s, debug: 3), colors: true) unless @path
    fail ArgumentError.new(
      "couldn't determine path from #{s.inspect}"
    ) unless @path
  end

  def self.make(path_array)

    return nil if path_array.nil?
    return path_array if path_array.is_a?(Dense::Path)

    path = Dense::Path.allocate
    path.instance_eval { @path = path_array }
    path.instance_eval { @original = path.to_s }

    path
  end

  def single?

    ! @path.find { |e| e.is_a?(Symbol) || e.is_a?(Hash) || e.is_a?(Array) }
  end

  def multiple?

    ! single?
  end

  def to_a

    @path
  end

  def length; @path.length; end
  alias size length

  def any?; @path.any?; end
  def empty?; @path.empty?; end

  def first; @path.first; end
  def last; @path.last; end

  def pop; @path.pop; end
  def shift; @path.shift; end

  def to_s

    o = StringIO.new

    @path.each { |e|
      s = _to_s(e, false)
      o << '.' unless o.size == 0 || '[.'.index(s[0, 1])
      o << s }

    s = o.string

    s[0, 2] == '..' ? s[1..-1] : s
  end

  def [](offset, count=nil)

    if count == nil && offset.is_a?(Integer)
      @path[offset]
    elsif count
      self.class.make(@path[offset, count])
    else
      self.class.make(@path[offset])
    end
  end

  def ==(other)

    other.class == self.class &&
    other.to_a == @path
  end

  def -(path)

    self.class.make(subtract(@path.dup, path.to_a.dup))
  end

  def narrow(outcome)

    single? ? outcome.first : outcome
  end

  def gather(data)

    _gather(0, [], nil, data, @path, [])
      .inject({}) { |h, hit| h[(hit[1] + [ hit[3] ]).inspect] ||= hit; h }
      .values
  end

  protected

  def _keys(o)

    return (0..o.length - 1).to_a if o.is_a?(Array)
    return o.keys if o.is_a?(Hash)
    nil
  end

  def _resolve_hash_key(o, k)

    return [ nil ] unless o.is_a?(Array)

    be = k[:start] || 0
    en = k[:end] || o.length - 1
    st = k[:step] || 1

    Range.new(be, en).step(st).to_a
  end

  def _resolve_key(o, k)

    return _resolve_hash_key(o, k) if k.is_a?(Hash)

    return [ k.to_s ] if o.is_a?(Hash)

    case k
    when /\Afirst\z/i then [ 0 ]
    when /\Alast\z/i then [ -1 ]
    else [ k ]
    end
  end

  def _resolve_keys(o, k)

    ks = k.is_a?(Hash) ? [ k ] : Array(k)
    ks = ks.inject([]) { |a, kk| a.concat(_resolve_key(o, kk)) }
  end

  def _stars(data0, data, key, path=[], acc=[])

#p [ :_stars, key, path, data0, data ]
    acc.push([ path, data0, data ]) if path.any?

    return acc unless data.is_a?(Hash) || data.is_a?(Array)

    return acc unless key
    key = key == :dotstar ? key : nil

    if data.is_a?(Array)
      data.each_with_index { |e, i| _stars(data, e, key, path + [ i ], acc) }
    else
      data.each { |k, v| _stars(data, v, key, path + [ k ], acc) }
    end

    acc
  end

  def _dot_gather(depth, path0, data0, data, path, acc)

#ind = '  ' * depth
#puts ind + "+--- _dot_gather()"
#puts ind + "| path0: #{path0.inspect}"
#puts ind + "| data: #{data.inspect}"
#puts ind + "| depth: #{depth} / path: #{path.inspect}"

    a = _gather(depth, path0, data0, data, path, []).select { |r| r.first }
    return acc.concat(a) if a.any?

    keys = _keys(data)

    return acc unless keys

    keys.each { |k|
      _dot_gather(depth + 1, path0 + [ k ], data, data[k], path, acc) }

    acc
  end

  def _index(o, k)

    case o
    when Array then k.is_a?(Integer) ? o[k] : nil
    when Hash then o[k]
    else nil
    end
  end

  def _gather(depth, path0, data0, data, path, acc)

    k = path.first
#ind = '  ' * depth
#print [ LG, DG, LB ][depth % 3]
#puts ind + "+--- _gather()"
#puts ind + "| path0: #{path0.inspect}"
#puts ind + "| data: #{data.inspect}"
#puts ind + "| depth: #{depth} / path: #{path.inspect}"
#puts ind + "| k: " + k.inspect

#puts RD + ind + "| -> " + [ false, path0[0..-2], data0, path0.last, path ].inspect if k.nil? && data.nil?
    return acc.push([ false, path0[0..-2], data0, path0.last, path ]) \
      if data.nil?

#puts GN + ind + "| -> " + [ true, path0[0..-2], data0, path0.last ].inspect if k.nil? && data.nil?
    return acc.push([ true, path0[0..-2], data0, path0.last ]) \
      if k.nil?

#puts RD + ind + "| -> " + [ false, path0[0..-2], data0, path0.last, path ].inspect unless data.is_a?(Array) || data.is_a?(Hash)
    return acc.push([ false, path0[0..-2], data0, path0.last, path ]) \
      unless data.is_a?(Array) || data.is_a?(Hash)

    return _dot_gather(depth, path0, data0, data, path[1..-1], acc) \
      if k == :dot

#puts ind + "| stars:\n" + _stars(data0, data, k).collect(&:first).to_pp if k == :star || k == :dotstar
    return _stars(data0, data, k).inject(acc) { |a, (pa, da0, da)|
      _gather(depth + 1, path0 + pa, da0, da, path[1..-1], a)
    } if k == :star || k == :dotstar

    keys = _resolve_keys(data, k)
#puts ind + "| keys: " + keys.inspect

    keys.inject(acc) { |a, kk|
      _gather(
        depth + 1, path0 + [ kk ], data, _index(data, kk), path[1..-1], a) }
  end

  def subtract(apath0, apath1)

    while apath0.any? && apath1.any? && apath0.last == apath1.last
      apath0.pop
      apath1.pop
    end

    apath0
  end

  def _to_s(elt, in_array)

    case elt
    when Hash
      s = [ "#{elt[:start]}:#{elt[:end]}", elt[:step] ].compact.join(':')
      in_array ? s : "[#{s}]"
    when Array
      "[#{elt.map { |e| _to_s(e, true) }.join(',')}#{elt.size < 2 ? ',' : ''}]"
    when String
      _str_to_s(elt, in_array)
    when :star
      '*'
    when :dot
      '.'
    when :dotstar
      '..*'
    else
      elt.to_s
    end
  end

  def _str_to_s(elt, in_array)

    return elt.inspect if in_array

    s = elt.to_s

    return "\\#{s}" if s == '.' || s == '*'
    return "[#{elt.inspect}]" if s =~ /["']/
    s
  end
end # Dense::Path

