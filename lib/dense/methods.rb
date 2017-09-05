
module Dense; class << self

  def get(o, path)

    Dense::Path.new(path).walk(o)
  end

  def set(o, path, value)

    path = Dense::Path.new(path)
    key = path.pop

#p path.walk(o)
#p key
#p value
    case c = path.walk(o)
    when Array then c[key] = value
    when Hash then c[key.to_s] = value
    else fail IndexError.new("Found no collection at #{path.to_s.inspect}")
    end

    value
  end
end; end

