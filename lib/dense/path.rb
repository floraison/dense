
class Dense::Path

  def initialize(s)

    s = ".#{s}" unless s[0, 1] == '[' || s[0, 2] == '.['

#Raabro.pp(Parser.parse(s, debug: 3))
    @path = Parser.parse(s)

#Raabro.pp(Parser.parse(s, debug: 3), colors: true) unless @path
    fail ArgumentError.new(
      "couldn't determine path from #{s.inspect}"
    ) unless @path
  end

  module Parser include Raabro

    # piece parsers bottom to top

    def dot(i); str(nil, i, '.'); end
    def comma(i); rex(nil, i, / *, */); end
    def bend(i); str(nil, i, ']'); end
    def bstart(i); str(nil, i, '['); end
    def dq(i); str(nil, i, '"'); end
    def sq(i); str(nil, i, "'"); end

    def name(i); rex(:name, i, /[a-z0-9_]+/i); end
    def off(i); rex(:off, i, /-?\d+/); end

    def dqname(i); seq(nil, i, :dq, :name, :dq); end
    def sqname(i); seq(nil, i, :sq, :name, :sq); end
    def star(i); str(:star, i, '*'); end
    def ses(i); rex(:ses, i, /-?\d*(:-?\d*){0,2}/); end

    def bindex(i); alt(:index, i, :dqname, :sqname, :star, :ses); end
    def bindexes(i); jseq(:bindexes, i, :bindex, :comma); end
    def bracket_index(i); seq(nil, i, :bstart, :bindexes, :bend); end
    def simple_index(i); alt(:index, i, :off, :star, :name); end

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
    def rewrite_star(t); '*'; end
    def rewrite_dotdot(t); '.'; end
    def rewrite_name(t); t.string; end
    def rewrite_off(t); t.string.to_i; end
    def rewrite_index(t); rewrite(t.sublookup); end
    def rewrite_bindexes(t);
      indexes = t.subgather.collect { |tt| rewrite(tt) }
      indexes.length == 1 ? indexes[0] : indexes.compact
    end

    def rewrite_path(t)
      t.subgather.collect { |tt| rewrite(tt) }
    end
  end

  def to_a

    @path
  end

  def walk(data)

    _walk(data, @path)
  end

  protected

  def _walk(data, path)

    return data if path.empty?

    case pa = path.first
    when '*'
      case data
      when Array then data.collect { |d| _walk(d, path[1..-1]) }
      when Hash then data.values.collect { |d| _walk(d, path[1..-1]) }
      else data
      end
    when Hash # start:end:step
      be = pa[:start] || 0
      en = pa[:end] || data.length - 1
      st = pa[:step] || 1
      Range.new(be, en).step(st).collect { |i| _walk(data[i], path[1..-1]) }
    when '.'
      _run(data, path[1..-1])
    else
      _walk(data[pa], path[1..-1])
    end
  end

  def _run(data, path)

    nil
  end
end

