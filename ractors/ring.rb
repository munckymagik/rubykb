RN = 1000
CR = Ractor.current

r = Ractor.new do
  p Ractor.receive
  CR << :fin
end

RN.times do
  r = Ractor.new r do |next_r|
    next_r << Ractor.receive + 1
  end
end

p :setup_ok
r << 0
p Ractor.receive
