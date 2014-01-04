describe Enumerable do
  example "It is mixed into Array, Hash and several other classes" do
    expect(Array.include? Enumerable).to be_true
    expect(Hash.include? Enumerable).to be_true
    expect(Range.include? Enumerable).to be_true
    expect(Dir.include? Enumerable).to be_true
    expect(Struct.include? Enumerable).to be_true
    expect(IO.include? Enumerable).to be_true
  end

  example "the including class must define #each" do
    expect(Array.new.respond_to? :each).to be_true
    expect(Hash.new.respond_to? :each).to be_true
    expect(Range.new(0,0,0).respond_to? :each).to be_true
  end

  class FakeCollection
    include Enumerable
    def each
      yield 1
      yield 2
      yield 3
    end
  end

  example "It provides the important common collection methods" do
    fc = FakeCollection.new
    expect(fc.map { |x| 2*x }).to eq([2, 4, 6])
    expect(fc.select { |x| x > 1 }).to eq([2, 3])
    # Note count, counts by enumerating so it will be O(n)
    expect(fc.count).to eq(3)
    expect(fc.map { |x| [x, x*2] }).to eq([[1, 2], [2, 4], [3, 6]])
    expect(fc.flat_map { |x| [x, x*2] }).to eq([1, 2, 2, 4, 3, 6])
    expect(fc.include? 2).to be_true
    expect(fc.reduce(0) { |accum, x| accum + x}).to eq(6)
    expect(fc.any? { |x| x % 2 == 0 }).to be_true
    # and so on ...
  end
end

describe Enumerator do
  class CustCollection
    def custom_each(extra_arg)
      yield extra_arg, 1
      yield extra_arg, 2
      yield extra_arg, 3
    end

    def each
      unless block_given?
        return to_enum(__method__) do
          3 # this is how to calculate the size
        end
      end
      3.times { |x| yield x }
    end
  end

  it "can be created using Object#to_enum" do
    cc = CustCollection.new
    cc_enum = cc.each # no block, to_enum used in each
    expect(cc_enum).to be_an_instance_of Enumerator
    expect(cc_enum.to_a).to eq([0, 1, 2])
  end

   it "can be created using Object#enum_for, which is an alias for #to_enum" do
    enum = "123".enum_for(:each_byte)
    expect(enum.to_a).to eq([49, 50, 51])

    enum_with_arg = CustCollection.new.enum_for(:custom_each, "!")
    expect(enum_with_arg.to_a).to eq([["!", 1], ["!", 2], ["!", 3]])
  end

  it "can be created using ::new with a block" do
    lazy_size = 3
    incrementer = Enumerator.new(lazy_size) do |yielder|
      yielder.yield 1
      yielder.yield 2
      yielder << 3 # << is an alias for yield
    end

    expect(incrementer.to_a).to eq([1,2,3])
    expect(incrementer.size).to eq(3)
  end

  it "is returned by many of the enumerable methods" do
    a = [1, 2, 3]
    expect(a.map).to be_an_instance_of Enumerator
    expect(a.drop_while).to be_an_instance_of Enumerator
    # Technically #each is part of Array itself
    expect(a.each).to be_an_instance_of Enumerator
  end

  it "can be used to chain execution of iteration" do

  end
end
