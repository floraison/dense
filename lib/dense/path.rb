
class Dense::Path

  def initialize(s)

#Raabro.pp(Parser.parse(s, debug: 3))
    @path = Parser.parse(s)

Raabro.pp(Parser.parse(s, debug: 3), colors: true) unless @path
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

    def dotdot(i); str(:dotdot, i, '.'); end
    def name(i); rex(:name, i, /[a-z0-9_]+/i); end
    def off(i); rex(:off, i, /-?\d+/); end

    def dqname(i); seq(nil, i, :dq, :name, :dq); end
    def sqname(i); seq(nil, i, :sq, :name, :sq); end
    def star(i); str(:star, i, '*'); end
    def ses(i); rex(:ses, i, /-?\d*(:-?\d*){0,2}/); end

    def bindex(i); alt(:index, i, :dqname, :sqname, :star, :ses); end
    def bindexes(i); jseq(:bindexes, i, :bindex, :comma); end
    def dindex(i); alt(:index, i, :off, :name, :dotdot); end

    def bracket_index(i); seq(nil, i, :bstart, :bindexes, :bend); end
    def dot_index(i); seq(nil, i, :dot, :dindex); end

    def then_index(i); alt(nil, i, :dot_index, :bracket_index); end
    def start_index(i); alt(nil, i, :dindex, :bracket_index); end

    def path(i); seq(:path, i, :start_index, :then_index, '*'); end

    # rewrite parsed tree

    def rewrite_ses(t)
      a = t.string.split(':').collect { |e| e.empty? ? nil : e.to_i }
      return a[0] if a[1] == nil && a[2] == nil
      { start: a[0], end: a[1], step: a[2] }
    end
    def rewrite_star(t); '*'; end
    def rewrite_dotdot(t); '..'; end
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

    if path.empty?
      data
    else
      _walk(data[path.first], path[1..-1])
    end
  end
end

