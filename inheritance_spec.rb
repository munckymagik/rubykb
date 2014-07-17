module Inheritance
  class Parent
    attr_accessor :inits
    attr_reader :counter
    def add_init(name)
      (@inits ||= []) << name
    end

    def initialize
      add_init(:parent)
      @thingey = :parent
    end

    def get_thingey_from_parent
      @thingey
    end

    def haircolor
      :brown
    end
    def eyecolor
      :green
    end
    def music_taste
      [:rock]
    end
    def do_thing(an_arg)
      an_arg
    end
  end

  class Child < Parent
    def initialize(call_super=nil)
      super() if call_super == :call_super
      add_init(:child)
      @thingey = :child
    end

    def get_thingey_from_child
      @thingey
    end

    def eyecolor
      :blue
    end
    def music_taste
      super + [:indie]
    end
    def do_thing
      :no_args
    end
  end

  describe "Inheritance" do
    context "Subclass initialization" do
      example "Child initializers override parent initializers just like normal methods" do
        expect(Child.new(:dont_call_super).inits).to eq([:child])
      end
      example "Child initializers must use super to invoke the parent's method" do
        expect(Child.new(:call_super).inits).to eq([:parent, :child])
      end
    end

    context "Method overriding rules" do
      example "Subclasses inherit superclass methods" do
        expect(Child.new.haircolor).to be(:brown)
      end
      example "Subclasses can override superclass methods" do
        expect(Parent.new.eyecolor).to be(:green)
        expect(Child.new.eyecolor).to be(:blue)
      end
      example "Super lets the subclass call the overridden parent's method" do
        expect(Child.new.music_taste).to eq([:rock, :indie])
      end
      example "The overriding method can accept a different of arguments" do
        expect(Parent.new.do_thing(:one_arg)).to be(:one_arg)
        expect(Child.new.do_thing).to be(:no_args)
      end
    end

    context "Instance variables are not affected by inheritance" do
      example "There is only one copy of each variable per instance" do
        c = Child.new
        expect(c.get_thingey_from_child).to eq(:child)
        expect(c.get_thingey_from_parent).to eq(:child)
      end
    end
  end
end

