# TODO refactor this
# * Need a consistent way of creating fixtures
# * Need to consider breaking into more than one file

class BlankClass
end

module ModuleA
  class ClassA
  end
end

class OuterClass
  class InnerClass
  end
end

module Factory

  def self.create_class_with_init
    Class.new do
      def initialize
        @init_called = true
      end

      def init_called?
        @init_called
      end
    end
  end

  def self.create_class_with_init_args
    Class.new do
      attr_reader :args

      def initialize(*args)
        @args = args
      end
    end
  end

  def self.create_obj_with_instance_var
    Class.new do
      def initialize
        @an_instance_variable = "a value"
      end
    end.new
  end
end

describe "Classes and Objects" do

  describe "Classes" do

    they "are stored as global constants on Object" do
      expect(Object.constants).to include :Array
      expect(Object.constants).to include :Hash
      expect(Object.constants).to include :Fixnum
      expect(Object.constants).to include :BlankClass
    end

    they "are declared using the class keyword" do
      expect(Object.constants).not_to include :DefinedByClassKeyword
      # Note this defines a global scope class that will not be GC'd
      class DefinedByClassKeyword; end
      expect(Object.constants).to include :DefinedByClassKeyword
    end

    they "are instances of the class object" do
      expect(BlankClass).to be_an_instance_of Class
    end

    they "have names" do
      expect(BlankClass.name).to eq("BlankClass")
    end

    they "can be nested within modules" do
      expect(ModuleA::ClassA.name).to eq("ModuleA::ClassA")
      expect(Object.constants).not_to include :ClassA
      expect(ModuleA.constants).to include :ClassA
    end

    they "can be nested within classes" do
      expect(OuterClass::InnerClass.name).to eq("OuterClass::InnerClass")
      expect(Object.constants).not_to include :InnerClass
      expect(OuterClass.constants).to include :InnerClass
    end
  end

  describe "Class Declarations" do
    # Borrowed from the Koans
    LastExpressionInClassStatement = class Dog
                                       21
                                     end

    they "return the value of the last expression evaluated inside" do
      expect(LastExpressionInClassStatement).to be(21)
    end

    SelfInsideOfClassStatement = class Dog
                                   self
                                 end

    specify "inside the declaration, self points to the class instance" do
      expect(SelfInsideOfClassStatement).to be(Dog)
    end
  end

  describe Class do
    it "inherits from Module" do
      expect(Class.superclass).to be(Module)
    end

    it "is itself an instance of Class" do
      expect(Class).to be_an_instance_of Class
    end

    it "is itself an Object" do
      expect(Class).to be_an Object
    end

    describe "::new" do
      def create_anon
        Class.new do |clazz|
          def clazz.f; "anon.f" end
          def g; "g" end
        end
      end

      it "provides a way to define anonymous classes" do
        anon = create_anon

        # TODO this should be split out to a spec for anon classes
        expect(anon).to be_an_instance_of Class
        expect(anon.superclass).to be(Object)
        expect(anon.to_s).to match(/^#<Class:0x[A-Fa-f0-9]+>/)
        expect(anon.f).to eq("anon.f")
        expect(anon.new.g).to eq("g")

        # NOTE because anon is not stored as a constant
        # it can be garbage collected
      end
    end
  end

  describe "Instantiation" do
    example "Objects are created by calling self.new" do
      o = Object.new
      expect(o).to be_an_instance_of(Object)
    end

    example "self.new calls #initialize" do
      class_with_init = Factory.create_class_with_init
      o = class_with_init.new
      expect(o.init_called?).to be_true
    end

    example "self.new passes its argument to #initialize" do
      clazz = Factory.create_class_with_init_args
      obj = clazz.new 1, 2, 3
      expect(obj.args).to eq([1, 2, 3])
    end
  end

  describe "Instance Variables" do
    let(:obj) { Factory.create_obj_with_instance_var }

    they "are set simply by assigning to them" do
      expect(obj.instance_variables).to eq([:@an_instance_variable])
    end

    they "cannot be accessed by code defined outside the class" do
      expect {
        obj.an_instance_variable
      }.to raise_error NoMethodError

      expect {
        eval "obj.@an_instance_variable"
      }.to raise_error SyntaxError
    end

    they "can be accessed using a deliberate backdoor, if you really need to" do
      value = obj.instance_variable_get("@an_instance_variable")
      expect(value).to eq("a value")
    end
  end

  describe "Accessor Methods" do
    they "can be generated automatically using attr_accessor"
    specify "read only accessors are created using attr_reader"
    specify "read only accessors are created using attr_writer"
  end

  describe "Class Variables" do
    class ClassVarExample
      @@class_var = 0

      def class_var
        @@class_var
      end

      def class_var= value
        @@class_var = value
      end
    end

    class ClassVarExampleAAAA < ClassVarExample; end
    class ClassVarExampleBBBB < ClassVarExample; end

    they "are shared across all instances of a class" do
      bob = ClassVarExample.new
      bob.class_var = 20

      john = ClassVarExample.new
      john.class_var = 10

      expect(john.class_var).to eq(bob.class_var)
      expect(bob.class_var).to eq(10)
    end

    they "are shared across all sub-classes" do
      bob = ClassVarExampleAAAA.new
      bob.class_var = 20

      john = ClassVarExampleBBBB.new
      john.class_var = 10

      expect(john.class_var).to eq(bob.class_var)
      expect(bob.class_var).to eq(10)
    end
  end

  # TODO this should be moved into the metaclasses_spec.rb file instead
  describe "Class Instance Variables" do
    # Another nicer example is at http://martinfowler.com/bliki/ClassInstanceVariable.html
    class ClassInstanceVarParent
      # Note: if we didn't use 'self' does this mean it would be defined on ClassInstanceVarParent?
      class << self
        attr_accessor :count
      end

      def initialize
        self.class.count ||= 0
        self.class.count += 1
      end
    end

    class ClassInstanceVarSubClassAAAA < ClassInstanceVarParent; end
    class ClassInstanceVarSubClassBBBB < ClassInstanceVarParent; end

    they "are defined on specific classes and not shared among all in a hierarchy" do
      ClassInstanceVarSubClassAAAA.new
      ClassInstanceVarSubClassBBBB.new

      expect(ClassInstanceVarParent.count).to be(nil)
      expect(ClassInstanceVarSubClassAAAA.count).to be(1)
      expect(ClassInstanceVarSubClassBBBB.count).to be(1)

      expect(ClassInstanceVarParent.instance_variables).to eq([])
      expect(ClassInstanceVarSubClassAAAA.instance_variables).to eq([:@count])
      expect(ClassInstanceVarSubClassBBBB.instance_variables).to eq([:@count])
    end
  end

  describe "Visibility" do
    example "public visibility"
    example "private visibility"
    example "protected visibility"
  end

  describe "Inheritance" do
    example "Method and variable overriding rules"
  end
end
