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

  it "can be used to chain execution of iteration"

end
