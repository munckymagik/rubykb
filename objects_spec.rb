
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

describe "Objects" do

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
    specify "write only accessors are created using attr_writer"
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

    they "are visible in the declaring class and its descendants" do
      expect(ClassVarExample.class_variables).to include(:@@class_var)
      expect(ClassVarExampleAAAA.class_variables).to include(:@@class_var)
    end

    they "are not visible in the declaring class's ancestors" do
      expect(ClassVarExample.superclass.class_variables).not_to include(:@@class_var)
    end
  end

  describe "Visibility" do
    example "public visibility"
    example "private visibility"
    example "protected visibility"
  end
end