describe "lambdas" do

  it "are a special type of Proc" do
    # given
    inc = lambda { |x| x + 1 }

    # then
    expect(inc).to be_an_instance_of(Proc)
  end

  it "can be defined using the special syntax ->() {}" do
    # given
    inc = ->(x) { x + 1 }

    # then
    expect(inc).to be_an_instance_of(Proc)
    expect(inc).to be_a_lambda
  end

  it "can be invoked by calling #call" do
    # given
    inc = lambda { |x| x + 1 }

    # when
    y = inc.call(99)

    # then
    expect(y).to eq(100)
  end

  it "cannot be invoked like a function using normal braces" do
    # given
    inc = lambda { |x| x + 1 }

    # then
    expect {
      # when
      # this tries to call 'inc' on the enclosing scope
      y = inc(99)
    }.to raise_error(NoMethodError)
  end

  it "can be invoked by calling as instance.(...)" do
    # given
    inc = lambda { |x| x + 1 }

    # when
    y = inc.(99)

    # then
    expect(y).to eq(100)
  end

  it "can be invoked using square brackets" do
    # given
    inc = lambda { |x| x + 1 }

    # when
    y = inc[99]

    # then
    expect(y).to eq(100)
  end
end
