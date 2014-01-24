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
        expect(prc.methods.include? :"()").to be_false
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

  context "comparison" do
    pending
  end

  context "properties" do
    describe "#===" do pending end
    describe "#arity" do pending end
    describe "#inspect" do pending end
    describe "#binding" do pending end
    describe "#hash" do pending end
    describe "#lambda?" do pending end
    describe "#parameters" do pending end
    describe "#source_location" do pending end
  end
end
