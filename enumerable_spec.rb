describe Enumerable do
  example "It is mixed into Array, Hash and several other classes" do
    expect(Array.include? Enumerable).to be_truthy
    expect(Hash.include? Enumerable).to be_truthy
    expect(Range.include? Enumerable).to be_truthy
    expect(Dir.include? Enumerable).to be_truthy
    expect(Struct.include? Enumerable).to be_truthy
    expect(IO.include? Enumerable).to be_truthy
  end

  example "the including class must define #each" do
    expect(Array.new.respond_to? :each).to be_truthy
    expect(Hash.new.respond_to? :each).to be_truthy
    expect(Range.new(0,0,0).respond_to? :each).to be_truthy
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
    expect(fc.include? 2).to be_truthy
    expect(fc.reduce(0) { |accum, x| accum + x}).to eq(6)
    expect(fc.any? { |x| x % 2 == 0 }).to be_truthy
    # and so on ...
  end
end
