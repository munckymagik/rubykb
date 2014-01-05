module MyMixin
  def say_hello
    puts "Hello #{name}"
  end
end

class MyClass
  include MyMixin

  def name
    "Dan"
  end
end

describe "Mixins" do
  example "they can be detected in an instance by calling is_a?" do
    c = MyClass.new
    expect(c.is_a? MyMixin).to be_true
    expect([].is_a? Enumerable).to be_true
  end

  example "they can be detected in an class by calling include?" do
    expect(MyClass.include? MyMixin).to be_true
  end

  example "all modules mixed-in to a class can be discovered in included_modules or ancestors" do
    expect(Array.included_modules.include? Enumerable).to be_true
    expect(MyClass.included_modules.include? MyMixin).to be_true
    expect(MyClass.ancestors.include? MyMixin).to be_true
  end

  example "Method and variable overriding rules"
end
