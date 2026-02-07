# frozen_string_literal: true

module Dense; class << self

  def get(o, path)

    pa = Dense::Path.make(path)
    r = pa.gather(o).inject([]) { |a, e| a << e[2][e[3]] if e.first; a }

    pa.narrow(r)
  end

  def fetch(o, path, default=::KeyError, &block)

    pa = Dense::Path.make(path)
    hits, misses = pa.gather(o).partition(&:first)

    if hits.empty?

      return pa.narrow(
        misses.collect { |m| call_default_block(o, path, block, m) }
      ) if block

      return pa.narrow(
        misses.collect { |m| default }
      ) if default != KeyError

      fail miss_error(path, misses.first)
    end

    pa.narrow(hits.collect { |e| e[2][e[3]] })
  end

  def set(o, path, value)

    Dense::Path.make(path)
      .gather(o)
      .each { |hit|
        validate(path, hit) if hit[0] == false
        hit[2][hit[3]] = value }

    value
  end

  def unset(o, path, nofail=false)

    pa = Dense::Path.make(path)
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

  def force_set(o, path, value)

    Dense::Path.make(path)
      .gather(o)
      .each { |hit|
        if hit[0] == false
          n = hit[4].first
          validate(path, hit) \
            if n.nil? && ! key_matches_collection?(hit[3], hit[2])
          hit[2][hit[3]] =
            if n.is_a?(String)
              {}
            else
              []
            end
          return force_set(o, path, value)
        end
        hit[2][hit[3]] = value }

    value
  end

  def insert(o, path, value)

    Dense::Path.make(path)
      .gather(o)
      .each { |hit|
        validate(path, hit) if hit[0] == false
        if hit[2].is_a?(Array)
          hit[2].insert(hit[3], value)
        else
          hit[2][hit[3]] = value
        end }

    value
  end

  def has_key?(o, path)

    !! Dense::Path.make(path).gather(o).find { |m| m[0] }
  end

  def path(path)

    Dense::Path.make(path)
  end

  def gather(o, path)

    Dense::Path.make(path).gather(o)
  end

  def paths(o, glob)

    Dense::Path.make(glob).enumerate(o)
  end

  def list(o, path)

    Dense::Path.make(path).list(o)
  end

  protected

  def key_matches_collection?(k, c)

    (c.is_a?(Hash) && k.is_a?(String)) ||
    (c.is_a?(Array) && k.is_a?(Integer))
  end

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

  # IndexError:
  #   Raised when the given index is invalid.
  # KeyError:
  #   Raised when the specified key is not found. It is a subclass of IndexError.

  def index_error(path, miss)

    if miss[2].is_a?(Array) || miss[2].is_a?(Hash)

      path1 = Dense::Path.make(miss[1] + [ miss[3] ]).to_s.inspect
      path2 = Dense::Path.make(miss[4]).to_s.inspect

      msg = "found nothing at #{path1}"
      msg = "#{msg} (#{path2} remains)" if path2 != '""'

      make_error(KeyError, msg, path, miss)

    else

      path1 = Dense::Path.make(miss[1]).to_s.inspect
      path2 = Dense::Path.make(miss[4]).to_s.inspect

      msg = "found no collection at #{path1} for key #{miss[3].inspect}"
      msg = "#{msg} (#{path2} remains)" if path2 != '""'

      make_error(IndexError, msg, path, miss)
    end
  end

  def type_error(path, miss)

    key = miss[3].inspect
    cla = miss[2].class
    pat = miss[1].empty? ? 'root' : Dense::Path.make(miss[1]).to_s.inspect

    make_error(TypeError, "no key #{key} for #{cla} at #{pat}", path, miss)
  end

  def miss_error(path, miss)

    if miss[2].is_a?(Array) && ! miss[3].is_a?(Integer)
      type_error(path, miss)
    else
      index_error(path, miss)
    end
  end

  def validate(path, miss)

    fail miss_error(path, miss) \
      if miss[4].any?
    fail type_error(path, miss) \
      if miss[2].is_a?(Array) && ! miss[2].is_a?(Integer)

    # else, no failure, carry on!
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

