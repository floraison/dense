
module Dense; class << self

  def get(o, path)

    pa = Dense::Path.new(path)
    r = pa.gather(o).inject([]) { |a, e| a << e[2][e[3]] if e.first; a }

    pa.single? ? r.first : r
  end

  def fetch(o, path, default=::KeyError, &block)

    pa = Dense::Path.new(path)
    r = pa.gather(o).partition(&:first)

    if r[0].empty?

      return pa.narrow(
        r[1].collect { |m| call_default_block(o, path, block, m) }
      ) if block

      return pa.narrow(
        r[1].collect { |m| default }
      ) if default != KeyError

      fail miss_error(path, r[1].first)
    end

    pa.narrow(r[0].collect { |e| e[2][e[3]] })
  end

  def set(o, path, value)

    Dense::Path.new(path)
      .gather(o)
      .each { |hit|
        fail_miss_error(path, hit) if hit[0] == false
        hit[2][hit[3]] = value }

    value
  end

  def unset(o, path, nofail=false)

    pa = Dense::Path.new(path)
    hits = pa.gather(o)

    hits.each { |h| fail miss_error(path, h) unless h[0] } unless nofail

    r = hits
      .sort_by { |e| "#{e[2].hash}|#{e[3]}" }
      .reverse
      .inject([]) { |a, e|
        next a.push(nil) unless e[0]
        k = e[3]
        a.push(e[2].is_a?(Array) ? e[2].delete_at(k) : e[2].delete(k)) }
      .reverse

    pa.narrow(r)
  end

  def insert(o, path, value)

    Dense::Path.new(path)
      .gather(o)
      .each { |hit|
        fail_miss_error(path, hit) if hit[0] == false
        if hit[2].is_a?(Array)
          hit[2].insert(hit[3], value)
        else
          hit[2][hit[3]] = value
        end }

    value
  end

  def has_key?(o, path)

    !! Dense::Path.new(path).gather(o).find { |m| m[0] }
  end

  protected

  module DenseError

    attr_accessor :full_path, :miss

    # Used by some "clients" (like flor) to relabel (change the error message)
    # a reraise.
    #
    def relabel(message)

      err = self.class.new(message)
      class << err; include DenseError; end
      err.set_backtrace(self.backtrace)
      err.full_path = self.full_path
      err.miss = self.miss

      err
    end
  end

  def make_error(error_class, message, path, miss)

    err = error_class.new(message)
    class << err; include DenseError; end
    err.full_path = path
    err.miss = miss

    err
  end

  def key_error(path, miss)

    path1 = Dense::Path.make(miss[1] + [ miss[3] ]).to_s.inspect
    path2 = Dense::Path.make(miss[4]).to_s.inspect

    msg = "Found nothing at #{path1}"
    msg = "#{msg} (#{path2} remains)" if path2 != '""'

    make_error(KeyError, msg, path, miss)
  end

  def type_error(path, miss)

    key = miss[3].inspect
    cla = miss[2].class
    pat = miss[1].empty? ? 'root' : Dense::Path.make(miss[1]).to_s.inspect

    make_error(TypeError, "No key #{key} for #{cla} at #{pat}", path, miss)
  end

  def miss_error(path, miss)

    if miss[2].is_a?(Array) && ! miss[3].is_a?(Integer)
      type_error(path, miss)
    else
      key_error(path, miss)
    end
  end

  def fail_miss_error(path, miss)

    fail miss_error(path, miss) \
      if miss[4].any?
    fail type_error(path, miss) \
      if miss[2].is_a?(Array) && ! miss[2].is_a?(Integer)
  end

  def call_default_block(o, path, block, miss)

      # [ collection, path,
      #   path before miss, collection at miss, key at miss, path after miss ]
      #
    args = [
      o, path,
      Dense::Path.make(miss[1]), miss[2], miss[3], Dense::Path.make(miss[4])
    ][0, block.arity]

    block.call(*args)
  end
end; end # Dense

