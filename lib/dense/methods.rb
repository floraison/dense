
module Dense; class << self

  def get(o, path)

    Dense::Path.new(path).walk(o)
  end
end; end

