class TestFodder
  def initialize(some_arg)
    @some_arg = some_arg
  end

  def get
    @some_arg
  end
end

TestFodder.new(123).get
