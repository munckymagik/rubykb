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

  describe Class do
    it "inherits from Module" do
      expect(Class.superclass).to be(Module)
    end

    it "is itself an instance of Class" do
      expect(Class).to be_an_instance_of Class
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

  example "There are two types of class/static variables"
  example "Class / static methods"
  example "public visibility"
  example "private visibility"
  example "protected visibility"
  example "Does it support multiple inheritance?"
  example "Method and variable overriding rules"
  example "Deal with overriding rules relating to mixins in the other file"
end
