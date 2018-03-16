
module Dense::Path::Parser include ::Raabro

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
  def blank(i); str(:blank, i, ''); end

  def name(i); rex(:name, i, /[-+%^<>a-zA-Z0-9_\/\\=?]+/); end
  def off(i); rex(:off, i, /-?\d+/); end

  def star(i); str(:star, i, '*'); end

  def ses(i) # start:end:step
    rex(
      :ses,
      i,
      /(
        (-?\d+)?:(-?\d+)?:(-?\d+)? |
        (-?\d+)?:(-?\d+)? |
        -?\d+
      )/x)
  end

  def escape(i); rex(:esc, i, /\\[.*]/); end

  def bindex(i); alt(:index, i, :dqname, :sqname, :star, :ses, :name, :blank); end
  def bindexes(i); jseq(:bindexes, i, :bindex, :comma); end
  def bracket_index(i); seq(nil, i, :bstart, :bindexes, :bend); end
  def simple_index(i); alt(:index, i, :off, :escape, :star, :name); end

  def dotdot(i); str(:dotdot, i, '.'); end

  def dot_then_index(i); seq(nil, i, :dot, :simple_index); end
  def index(i); alt(nil, i, :dot_then_index, :bracket_index, :dotdot); end

  def path(i); rep(:path, i, :index, 1); end # it starts here

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

  def rewrite_blank(t); nil; end

  def rewrite_qname(t); t.string[1..-2]; end
  def rewrite_name(t); t.string; end

  def rewrite_path(t)
    t.subgather.collect { |tt| rewrite(tt) }
  end
end # Dense::Path::Parser

