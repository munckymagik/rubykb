r3 = Ractor.new Ractor.current do |cr|
  cr.send Ractor.receive + 'r3'
end

r2 = Ractor.new r3 do |r3|
  r3.send Ractor.receive + 'r2'
end

r1 = Ractor.new r2 do |r2|
  r2.send Ractor.receive + 'r1'
end

r1 << 'r0'
p Ractor.receive
