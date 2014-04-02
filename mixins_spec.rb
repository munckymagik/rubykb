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

  describe "include" do

    context "Modules" do
      module A
        CONSTANT = 1

        def self.static_method
          :hi
        end

        def inst_method
          :bye
        end
      end

      module B
        include A
      end

      class C
        include A
      end

      specify "module A has a static method and an instance method" do
        expect(A.static_method).to eq(:hi)
        expect {
          A.inst_method
        }.to raise_error(NoMethodError)
      end

      specify "module A is included in module B" do
        expect(B.include? A).to be_true
      end

      specify "but that doesn't add anything useful to B" do
        expect {
          B.static_method
        }.to raise_error(NoMethodError)
        expect {
          B.inst_method
        }.to raise_error(NoMethodError)
      end
    end

    context "Classes" do
      specify "class C includes module A via module B" do
        expect(C.include? A).to be_true
      end

      specify "class C inherits module A's instance methods" do
        expect(C.new.inst_method).to eq(:bye)
      end

      specify "but class C does not inherit module A's class methods" do
        expect {
          C.static_method
        }.to raise_error(NoMethodError)
      end
    end
  end

  describe "extend"
end
