describe Proc do

  context "creation" do
    describe "::new" do
      context "when passed a block" do
        it "creates a proc using the given block" do
          prc = Proc.new { "a direct block" }

          expect(prc).to be_an_instance_of Proc
          expect(prc.call).to eq("a direct block")
        end
      end

      context "when passed no block" do
        def create_proc_with_block
          # Implicitly uses factory method's block
          Proc.new
        end

        it "creates a proc using the block of the enclosing method" do
          prc = create_proc_with_block { "an indirect block" }

          expect(prc).to be_an_instance_of Proc
          expect(prc.call).to eq("an indirect block")
        end

        it "raises an ArgumentError when passed nothing" do
          expect {
            Proc.new
          }.to raise_error ArgumentError
        end
      end
    end

    describe "Kernel::proc" do
      it "is a equivalent to Proc::new" do
        prc = proc { "hello" }
        expect(prc.call).to eq("hello")
      end
    end

    def convert_block_to_proc(&block)
      block
    end

    it "can be done by passing a block to a method with an explicit block parameter" do
      prc = convert_block_to_proc { "hello" }
      expect(prc).to be_an_instance_of Proc
    end
  end

  context "invocation" do
    describe "#call" do
      it "invokes the block" do
        result = proc { "hello" }.call
        expect(result).to eq("hello")
      end

      it "sets the block parameters to the values given in its params" do
        prc = proc { |x, y, *z| "#{x}, #{y}, #{z}" }
        expect(prc.call 1, 2, 3, 4).to eq("1, 2, [3, 4]")
      end
    end

    describe "Proc 'tricks'" do
      # NOTE Lambdas don't do this stuff

      it "silently discards extra parameters if created using Proc::new or Kernel::new" do
        prc = proc { |x| x }
        expect(prc.call(1, 2)).to eq(1)
      end

      it "provides nil for missing arguments" do
        prc = proc { |x, y| [x, y] }
        expect(prc.call(1)).to eq([1, nil])
      end

      it "expands a single array argument" do
        prc = proc { |x, y| [x, y] }
        expect(prc.call([1, 2])).to eq([1, 2])
        expect(prc.call([1, 2], 3)).to eq([[1, 2], 3])
      end
    end

    describe "#[]" do
      it "is an alias for #call" do
        prc = proc {}
        expect(prc.method :[]).to eq(prc.method :call)
      end
    end

    describe "#()" do
      it "is syntax sugar that invokes #call" do
        prc = proc { |x, y, *z| "#{x}, #{y}, #{z}" }
        expect(prc.(1, 2, 3, 4)).to eq("1, 2, [3, 4]")
      end

      it "is not listed as a member of #methods" do
        prc = proc {}
        expect(prc.methods.include? :"()").to be_falsey
      end
    end

    describe "#===" do
      it "invokes the proc" do
        # given
        y = 0
        prc = proc { y = 1 }

        # when
        prc === nil

        # then
        expect(y).to eq(1)
      end

      it "passes its argument to the proc" do
        # given
        y = 0
        prc = proc { |x| y = x }

        # when
        prc === 1

        # then
        expect(y).to eq(1)
      end

      it "passes multiple arguments to the proc when invoked as a function" do
        # given
        y = 0
        prc = proc { |x, x1| y = x + x1 }

        # when
        prc.===(1, 2)

        # then
        expect(y).to eq(3)
      end

      it "can only pass multiple args when invoked as an operator by using 'Proc Tricks'" do
        # given
        y = 0
        prc = proc { |x, x1| y = x + x1 }

        # when
        prc === [1, 2] # Proc Trick: auto-expand array argument

        # then
        expect(y).to eq(3)
      end

      it "returns the value of the last expression in the proc" do
        # given
        prc = proc { 42 }

        # then
        expect(prc === 0).to eq(42)
      end

      it "is to allow a proc object to be the target of a when clause in a case statement" do
        # given
        is_42 = ->(x) { x == 42 }
        is_24 = ->(x) { x == 24 }
        check_it = ->(x) {
          case x
            when is_42 then "yay 42"
            when is_24 then "yay 24"
          end
        }

        # then
        expect(check_it[42]).to eq("yay 42")
        expect(check_it[24]).to eq("yay 24")
      end
    end
  end

  context "manipulation" do
    describe "#to_proc" do
      it "returns self" do
        prc = proc {}
        expect(prc.to_proc).to be(prc)
      end
    end

    describe "#curry" do
      let(:prc) { proc { |x, y, z| x + y + z } }

      it "returns a curried proc that executes the original" do
        curried_proc = prc.curry
        expect(curried_proc).not_to be(prc)
        expect(curried_proc.call(1, 2, 3)).to eq(prc.call(1, 2, 3))
      end

      describe "the curried proc" do
        it "invokes the original proc only if enough arguments are passed" do
          curried_proc = prc.curry.call(1, 2)
          expect(curried_proc).to be_an_instance_of Proc
        end

        it "otherwise returns another curried proc that takes the rest of the arguments" do
          curried_proc = prc.curry.call(1, 2)
          expect(curried_proc.call(3)).to eq(6)
        end
      end

      describe "the optional arity argument" do
        it "specifies how many arguments should be expected before invoking the original" do
          curried_proc = prc.curry(4)[1, 2, 3]
          expect(curried_proc).to be_an_instance_of Proc
          expect(curried_proc.call("forth argument is ignored but triggers invocation")).to eq(6)
        end
      end
    end
  end

  context "properties" do
    describe "#arity" do
      it "returns the number of arguments expected by the proc" do
        prc = proc {}
        expect(prc.arity).to eq(0)

        prc = proc { |x, y| }
        expect(prc.arity).to eq(2)

        # NOTE: It is more complicated than this where optional or defaulted arguments or lambdas involved
      end
    end

    describe "#binding" do
      def fred(param)
        proc {}
      end

      it "provides a way to access the variables in scope from within the proc" do
        b = fred(99)
        expect(eval("param", b.binding)).to eq(99)
      end
    end

    describe "#lambda?" do
      it "return true for any Proc object for which argument handling is rigid" do
        expect((lambda {}).lambda?).to be_truthy
      end

      it "return false for any Proc object for which argument handling is NOT rigid" do
        expect((proc {}).lambda?).to be_falsey
      end
    end

    describe "#parameters" do
      it "returns info on a proc's parameters" do
        prc = lambda { |x, y=42, *other| }
        expect(prc.parameters).to eq([
          [:req, :x],
          [:opt, :y],
          [:rest, :other]
          ])
      end

      it "marks proc params as optional" do
        procproc = proc { |x, y| }
        expect(procproc.parameters).to eq([[:opt, :x], [:opt, :y]])
      end

      it "marks lambda params as not optional" do
        lambdaproc = lambda { |x, y| }
        expect(lambdaproc.parameters).to eq([[:req, :x], [:req, :y]])
      end
    end
  end
end
