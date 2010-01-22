re = []
thread1 = Thread.new do
  p 'haha'
end

thread2 = Thread.new do
  p 'ahah'
end

thread3 = Thread.new do
  p 'ihih'
end
re << thread1
re << thread2
re << thread3

re.each do |t|
  t.join
end
