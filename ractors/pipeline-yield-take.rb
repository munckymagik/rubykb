r1 = Ractor.new do
  'r1'
end

r2 = Ractor.new(r1) do |r1|
  r1.take + 'r2'
end

r3 = Ractor.new(r2) do |r2|
  r2.take + 'r3'
end

p r3.take
