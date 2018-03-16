
class Dense::Path

  attr_reader :original

  def initialize(s)

    @original = s

    fail ArgumentError.new(
      "Argument is a #{s.class}, not a String"
    ) unless s.is_a?(String)

    s = ".#{s}" unless s[0, 1] == '[' || s[0, 2] == '.['

#Raabro.pp(Parser.parse(s, debug: 3))
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

  def to_a

    @path
  end

  def length; @path.length; end
  alias size length

  def any?; @path.any?; end
  def empty?; @path.empty?; end

  def to_s

    o = StringIO.new

    @path.each { |e|
      s = _to_s(e, false)
      o << '.' unless o.size == 0 || '[.'.index(s[0, 1])
      o << s }

    s = o.string

    s[0, 2] == '..' ? s[1..-1] : s
  end

  def walk(data, default=nil, &block)

    _walk(data, @path)

  rescue IndexError => ie

    return yield(@original, self) if block
    return default if default != nil && default != IndexError

    fail ie.expand(self) if ie.respond_to?(:expand)

    raise
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

  def last

    @path.last
  end

  def pop

    @path.pop
  end

  def -(path)

    self.class.make(subtract(@path.dup, path.to_a.dup))
  end

  protected

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

  def _walk(data, path)

#p [ 'd:', data, 'p:', path ]
    return data if path.empty?

    case pa = path.first
    when :dot then _walk_dot(data, pa, path)
    when :star then _walk_star(data, pa, path)
    when Hash then _walk_start_end_step(data, pa, path)
    when String then _walk(_sindex(data, path), path[1..-1])
    when Integer then _walk_int(data, pa, path)
    else fail IndexError.new("Unwalkable index in path: #{pa.inspect}")
    end
  end

  def _walk_star(data, pa, path)

    case data
    when Array then data.collect { |d| _walk(d, path[1..-1]) }
    when Hash then data.values.collect { |d| _walk(d, path[1..-1]) }
    else data
    end
  end

  def _walk_dot(data, pa, path)

    _run(data, path[1])
      .inject([]) { |a, d|
        a.concat(
          begin
            [ _walk(d, path[2..-1]) ]
          rescue NotIndexableError
            []
          end) }
  end

  def _walk_start_end_step(data, pa, path)

    be = pa[:start] || 0
    en = pa[:end] || data.length - 1
    st = pa[:step] || 1
    Range.new(be, en).step(st).collect { |i| _walk(data[i], path[1..-1]) }
  end

  def _walk_int(data, pa, path)

    if data.is_a?(Array)
      return _walk(data[pa], path[1..-1])
    end

    if data.is_a?(Hash)
      return _walk(data[pa], path[1..-1]) if data.has_key?(pa)
      pa = pa.to_s
      return _walk(data[pa], path[1..-1]) if data.has_key?(pa)
    end

    fail NotIndexableError.new(data, nil, path[1..-1])
  end

  def _sindex(data, path)

    key = path.first

    case data
    when Hash
      fail NotIndexableError.new(
        data, nil, path[1..-1]) unless data.has_key?(key)
      data[key]
    when Array
      case key
      when /\Afirst\z/i then data[0]
      when /\Alast\z/i then data[-1]
      else fail IndexError.new("Cannot index array with #{key.inspect}")
      end
    else
      fail IndexError.new(
        "Cannot index #{data.class} with #{key.inspect}")
    end
  end

  def _run(d, key)

    case d
    when Hash then _run_hash(d, key)
    when Array then _run_array(d, key)
    else key == :star ? [ d ] : []
    end
  end

  def _run_hash(d, key)

    if key == :star
      [ d ] + d.values.inject([]) { |a, v| a.concat(_run(v, key)) }
    else
      d.inject([]) { |a, (k, v)| a.concat(k == key ? [ v ] : _run(v, key)) }
    end
  end

  def _run_array(d, key)

    (key == :star ? [ d ] : []) +
    d.inject([]) { |r, e| r.concat(_run(e, key)) }
  end
end # Dense::Path

