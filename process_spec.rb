RSpec.describe Process do
  describe 'forking and killing' do
    it 'can fork and kill a subprocess cleanly' do
      pid = Process.fork do
        stop = false
        Signal.trap('INT') { stop = true }

        deadline = Time.now + 5
        until stop
          sleep 0.010

          if Time.now > deadline
            raise 'exceeded deadline without receiving a signal'
          end
        end
      end

      sleep 0.050
      Process.kill('INT', pid)
      _, status = Process.wait2
      expect(status.exitstatus).to eq(0)
    end
  end
end
