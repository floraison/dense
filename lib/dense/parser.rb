
module Dense::Path::Parser include ::Raabro

  # piece parsers bottom to top

  def rxnames(i)

    rex(:rxnames, i, %r{
      /(
        \\[\/bfnrt] |
        \\u[0-9a-fA-F]{4} |
        [^/\b\f\n\r\t]
      )*/[imxouesn]*
    }x)
  end

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

  def bindex(i)
    alt(:index, i, :dqname, :sqname, :star, :ses, :rxnames, :name, :blank)
  end
  def bindexes(i)
    jseq(:bindexes, i, :bindex, :comma)
  end

  def simple_index(i)
    alt(:index, i, :off, :escape, :star, :rxnames, :name)
  end

  def dotdot(i); str(:dotdot, i, '.'); end
  def dotdotstar(i); rex(:dotdotstar, i, /(\.\.\*|\.\[\*\])/); end
  def bracket_index(i); seq(nil, i, :bstart, :bindexes, :bend); end
  def dot_then_index(i); seq(nil, i, :dot, :simple_index); end

  def index(i)
    alt(nil, i, :dot_then_index, :bracket_index, :dotdotstar, :dotdot)
  end

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
  def rewrite_dotdotstar(t); :dotstar; end
  def rewrite_off(t); t.string.to_i; end
  def rewrite_index(t); rewrite(t.sublookup); end
  def rewrite_bindexes(t);
    indexes = t.subgather.collect { |tt| rewrite(tt) }
    indexes.length == 1 ? indexes[0] : indexes.compact
  end

  def rewrite_blank(t); nil; end

  ENCODINGS = {
    'u' => 'UTF-8', 'e' => 'EUC-JP', 's' => 'Windows-31J', 'n' => 'ASCII-8BIT' }
  R_ENCODINGS = ENCODINGS
    .inject({}) { |h, (k, v)| h[v] = k; h }

  def rewrite_rxnames(t)

    m = t.string.match(/\A\/(.+)\/([imxuesn]*)\z/)

    s = m[1]

    e = ENCODINGS[(m[2].match(/[uesn]/) || [])[0]]
    #s = s.force_encoding(e) if e
    s = s.encode(e) if e

    flags = 0
    flags = flags | Regexp::EXTENDED if m[2].index('x')
    flags = flags | Regexp::IGNORECASE if m[2].index('i')
    #flags = flags | Regexp::MULTILINE if m[2].index('m')
    flags = flags | Regexp::FIXEDENCODING if e

    Regexp.new(s, flags)
  end

  def rewrite_qname(t); t.string[1..-2]; end
  def rewrite_name(t); t.string; end

  def rewrite_path(t)

    t.subgather
      .collect { |tt|
        rewrite(tt) }
      .inject([]) { |a, e| # remove double :dot
        next (a << e) unless a.last == :dot
        a.pop if e == :dotstar
        a << e unless e == :dot
        a }
  end
end # Dense::Path::Parser

