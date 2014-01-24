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

  describe "Inheritance" do
    # TODO use a separate spec
    example "Method and variable overriding rules"
  end
end
