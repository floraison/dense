
class Dense::Path

  def initialize(s)

#Raabro.pp(Parser.parse(s, debug: 3))
    @path = Parser.parse(s)

    fail ArgumentError.new(
      "couldn't determine path from #{s.inspect}"
    ) unless @path
  end

  def to_a

    @path
  end

  module Parser include Raabro

    # piece parsers bottom to top

    def dot(i); str(nil, i, '.'); end
    def name(i); rex(:name, i, /[a-z0-9_]+/i); end
    def off(i); rex(:off, i, /\d+/); end
    def index(i); alt(:index, i, :off, :name); end
    def dot_index(i); seq(nil, i, :dot, :index); end
    def path(i); seq(:path, i, :index, :dot_index, '*'); end

    # rewrite parsed tree

    def rewrite_name(t); t.string; end
    def rewrite_off(t); t.string.to_i; end
    def rewrite_index(t); rewrite(t.sublookup(nil)); end
    def rewrite_path(t); t.subgather(:index).collect { |tt| rewrite(tt) }; end
  end
end

