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
    expect(c.is_a? MyMixin).to be_truthy
    expect([].is_a? Enumerable).to be_truthy
  end

  example "they can be detected in an class by calling include?" do
    expect(MyClass.include? MyMixin).to be_truthy
  end

  example "all modules mixed-in to a class can be discovered in included_modules or ancestors" do
    expect(Array.included_modules.include? Enumerable).to be_truthy
    expect(MyClass.included_modules.include? MyMixin).to be_truthy
    expect(MyClass.ancestors.include? MyMixin).to be_truthy
  end

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

      specify "module A has a static method and an instance method" do
        expect(A.static_method).to eq(:hi)
        expect {
          A.inst_method
        }.to raise_error(NoMethodError)
      end

      context "including into other modules" do

        module B
          include A
        end

        specify "module A is included in module B" do
          expect(B.include? A).to be_truthy
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
    end

    context "including into a classes" do
      class C
        include A
      end

      specify "class C includes module A" do
        expect(C.include? A).to be_truthy
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

  describe "extend" do
    class D
      extend A
    end

    specify "class D extends module A" do
      expect(D.respond_to? :inst_method)
      expect(D.inst_method).to eq(:bye)
    end

    specify "you can detect extended modules in the singleton_class's includes" do
      expect(D.singleton_class.included_modules).to include(A)
    end

    specify "extending a class with a module brings in the module's instance methods as class methods" do
      expect(D.inst_method).to eq(:bye)
    end

    specify "module class methods are not added to the extending class" do
      expect {
        D.static_method
      }.to raise_error(NoMethodError)
    end

    module ComposedModule
      extend A
    end

    example "extending into another module allows you to compose modules" do
      expect(ComposedModule.inst_method).to eq(:bye)
    end
  end

  module Foo
    def self.included(including_class)
      # Pegs on the extend operation here, when this module is included into a
      # class
      including_class.extend(ClassMethods)
    end

    module ClassMethods
      def a_class_method
        :hi_from_class_method
      end
    end

    def an_instance_method
      :hi_from_instance_method
    end
  end

  class Bazz
    include Foo
  end

  example "you can bring in both class methods and instance methods when you include" do
    expect(Bazz.a_class_method).to eq(:hi_from_class_method)
    expect(Bazz.new.an_instance_method).to eq(:hi_from_instance_method)
  end

  context "Method and variable overriding rules" do
    class Pet
      def speak
        "Woof"
      end
    end

    module Cat
      def speak
        "Mieow"
      end

      def cry
        "rawwwwwwwwmmmrrr"
      end
    end

    class MyPet
      include Cat

      def speak
        "moooo"
      end
    end

    module Pig
      def self.included(including_class)
        including_class.class_eval do
          define_method "speak" do
            "oink"
          end
        end
      end
    end

    class AnotherPet
      include Pig

      def speak
        "meep"
      end
    end

    context "local instance methods take precedence" do
      specify "including Cat into pet" do
        Pet.include(Cat)
        expect(Pet.new.speak).to eq("Woof")
      end

      specify "including Cat into MyPet" do
        expect(MyPet.new.speak).to eq("moooo")
      end

      specify "including Pet into AnotherPet" do
        expect(AnotherPet.new.speak).to eq('meep')
      end
    end

    context "forcing a modules methods to have precedence" do
      specify "the last version of a method to be defined wins" do
        # Equivalent to writing the include line at the bottom of the class
        # definition
        Pet.include(Pig)
        expect(Pet.new.speak).to eq('oink')
      end
    end

  end

end
