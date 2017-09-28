
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

  module Parser include Raabro

    # piece parsers bottom to top

    def dqname(i)

      rex(:qname, i, %r{
        "(
          \\["\\\/bfnrt] |
          \\u[0-9a-fA-F]{4} |
          [^"\\\b\f\n\r\t]
        )*"
      }x)
    end

    def sqname(i)

      rex(:qname, i, %r{
        '(
          \\['\\\/bfnrt] |
          \\u[0-9a-fA-F]{4} |
          [^'\\\b\f\n\r\t]
        )*'
      }x)
    end

    def dot(i); str(nil, i, '.'); end
    def comma(i); rex(nil, i, / *, */); end
    def bend(i); str(nil, i, ']'); end
    def bstart(i); str(nil, i, '['); end

    def name(i); rex(:name, i, /[-+%^<>a-zA-Z0-9_\/\\]+/); end
    def off(i); rex(:off, i, /-?\d+/); end

    def star(i); str(:star, i, '*'); end
    def ses(i); rex(:ses, i, /-?\d*(:-?\d*){0,2}/); end

    def escape(i); rex(:esc, i, /\\[.*]/); end

    def bindex(i); alt(:index, i, :dqname, :sqname, :star, :ses); end
    def bindexes(i); jseq(:bindexes, i, :bindex, :comma); end
    def bracket_index(i); seq(nil, i, :bstart, :bindexes, :bend); end
    def simple_index(i); alt(:index, i, :off, :escape, :star, :name); end

    def dotdot(i); str(:dotdot, i, '.'); end

    def dot_then_index(i); seq(nil, i, :dot, :simple_index); end
    def index(i); alt(nil, i, :dot_then_index, :bracket_index, :dotdot); end

    def path(i); rep(:path, i, :index, 1); end

    # rewrite parsed tree

    def rewrite_ses(t)
      a = t.string.split(':').collect { |e| e.empty? ? nil : e.to_i }
      return a[0] if a[1] == nil && a[2] == nil
      { start: a[0], end: a[1], step: a[2] }
    end
    def rewrite_esc(t); t.string[1, 1]; end
    def rewrite_star(t); :star; end
    def rewrite_dotdot(t); :dot; end
    def rewrite_off(t); t.string.to_i; end
    def rewrite_index(t); rewrite(t.sublookup); end
    def rewrite_bindexes(t);
      indexes = t.subgather.collect { |tt| rewrite(tt) }
      indexes.length == 1 ? indexes[0] : indexes.compact
    end

    def rewrite_qname(t); t.string[1..-2]; end
    def rewrite_name(t); t.string; end

    def rewrite_path(t)
      t.subgather.collect { |tt| rewrite(tt) }
    end

  end

  def to_a

    @path
  end

  def length; @path.length; end
  alias size length

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

  class NotIndexableError < ::IndexError

    attr_reader :container_class, :root_path, :remaining_path

    def initialize(container, root_path, remaining_path, message=nil)

      @container_class = container.is_a?(Class) ? container : container.class

      @root_path = Dense::Path.make(root_path)
      @remaining_path = Dense::Path.make(remaining_path)

      if message
        super(
          message)
      elsif @root_path
        super(
          "Found nothing at #{fail_path.to_s.inspect} " +
          "(#{@remaining_path.original.inspect} remains)")
      else
        super(
          "Cannot index instance of #{container_class} " +
          "with #{@remaining_path.original.inspect}")
      end
    end

    def expand(root_path)

      err = self.class.new(container_class, root_path, remaining_path, nil)
      err.set_backtrace(self.backtrace)

      err
    end

    def relabel(message)

      err = self.class.new(container_class, root_path, remaining_path, message)
      err.set_backtrace(self.backtrace)

      err
    end

    def fail_path

      @fail_path ||= (@root_path ? @root_path - @remaining_path : nil)
    end
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
      #in_array ? elt.inspect : elt.to_s
      #in_array ? _quote_s(elt) : _maybe_quote_s(elt)
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

    return data if path.empty?

    case pa = path.first
    when :dot then _walk_dot(data, pa, path)
    when :star then _walk_star(data, pa, path)
    when Hash then _walk_start_end_step(data, pa, path)
    when Integer then _walk_int(data, pa, path)
    when String then _walk(_sindex(data, pa), path[1..-1])
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

    fail NotIndexableError.new(data, nil, path)
  end

  def _sindex(data, key)

    case data
    when Hash
      data[key]
    when Array
      case key
        when /\Afirst\z/i then data[0]
        when /\Alast\z/i then data[-1]
        else fail IndexError.new("Cannot index array with #{key.inspect}")
      end
    else
      fail IndexError.new("Cannot index #{data.class} with #{key.inspect}")
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
end

