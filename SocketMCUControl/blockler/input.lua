for count = 1, 10 do
  coroutine.yield(1000)
  print((string.format("#%06x", math.random(0, 2^24 - 1))))
end
