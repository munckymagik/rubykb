# Question: are signal handler blocks executed on the main thread?

puts "Main thread: #{Thread.current.object_id}"

running = true

Signal.trap('INT') do
  puts "Signal thread: #{Thread.current.object_id}"
  running = false
end

t = Thread.new do
  while running
    puts "Loop thread: #{Thread.current.object_id}"
    sleep(1)
  end
end

t.join
