
class Dense::Path::NotIndexableError < ::IndexError

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
        "Found nothing at #{fail_path.to_s.inspect}" +
        (@remaining_path.any? ?
         " (#{@remaining_path.original.inspect} remains)" :
         ''))
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
end # Dense::Path::NotIndexableError

