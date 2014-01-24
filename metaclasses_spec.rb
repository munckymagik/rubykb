describe "Meta Classes" do
  describe "self" do

    SelfDemoClassObject = class SelfDemo
      self
    end

    it "is the class object when referred to inside a class definition" do
      expect(SelfDemoClassObject).to be(SelfDemo)
    end

    class SelfDemo
      def get_self
        self
      end
    end

    it "is the object instance when referred to inside an instance method" do
      obj = SelfDemo.new
      expect(obj.get_self).to be(obj)
    end

    SelfDemoMetaClassObject = class << SelfDemo
      self
    end

    it "is the metaclass (singleton) object when referred to inside a "\
       "'class << obj' block" do
      expect(SelfDemoMetaClassObject).to be(SelfDemo.singleton_class)
    end
  end

  describe "Method Scopes" do

    # A helper to get the list of methods defined directly in a class
    def methods_defined_in(clazz)
      # Passing false filters out all methods not defined directly in clazz
      # See Module#instance_methods, although note the documentation is
      # wrong it says false is the default, it's not.
      clazz.instance_methods(false)
    end

    describe "Instance Methods" do

      class MethodDemo
        def an_instance_method
          :hello_from_instance
        end
      end

      they "are defined in class definitions" do
        expect(methods_defined_in(MethodDemo)).to eq([:an_instance_method])
      end

      they "are invoked upon objects" do
        obj = MethodDemo.new
        #require 'pry'
        #binding.pry
        expect(obj.methods).to include(:an_instance_method)
        expect(obj.an_instance_method).to eq(:hello_from_instance)
      end
    end

    describe "Class Methods" do

      class MethodDemo
        def self.a_class_method
          :hello_from_class
        end
      end

      they "are invoked upon class objects" do
        expect(MethodDemo.methods).to include(:a_class_method)
        expect(MethodDemo.a_class_method).to eq(:hello_from_class)
      end

      # Define a class method by opening the class singleton directly
      class << MethodDemo
        def another_class_method
          :yet_another
        end
      end

      # Define a class method by opening the singleton within the class
      class MethodDemo
        class << self
          def another_class_method2
            :and_another
          end
        end
      end

      they "are defined on the class's singleton/meta class" do
        expect(methods_defined_in(MethodDemo.singleton_class)).to \
          include(:a_class_method,
                  :another_class_method,
                  :another_class_method2)
      end
    end

    describe "Singleton Methods" do

      def create_obj_with_singleton_method
        obj = Object.new
        def obj.extra_method
          :hello_from_singleton
        end

        obj
      end

      let(:obj) { create_obj_with_singleton_method }

      they "are defined on specific object instances" do
        expect(obj.methods).to include(:extra_method)
      end

      they "are not added to an object's class" do
        expect(methods_defined_in(Object)).not_to include(:extra_method)
      end

      they "are actually defined on anonymous classes known as metaclasses " \
           "or singletons" do
        expect(methods_defined_in(obj.singleton_class)).to include(:extra_method)
      end
    end
  end
end
