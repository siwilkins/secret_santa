require 'mail'

def reset!
  @family = %w{Kate Jon Jo Janet Mike Sofia Bec Mark Si Hazel}
  @givers = @family.dup
  @receivers = @family.dup
  @buyers = []
end


def partners?(a, b)
  @family.index(a) / 2 == @family.index(b) / 2
end

def failed?
  available = (@givers + @receivers).uniq
  available.size == 1 || (available.size == 2 && partners?(*available))
end 

reset!

while !@givers.empty?
  reset! if failed?
  giver = @givers.shift
  n = Math.send(:rand, @receivers.length)
  receiver = @receivers[n]
  if partners?(giver, receiver)
    @givers << giver
  else
    @receivers.delete receiver
    @buyers << [giver, receiver]
  end
end

@buyers.each do |giver, receiver|
  puts "#{giver} buys for #{receiver}"
  mail = Mail.new do
    from 'secret@santa.com'
    to 'si.wilkins@gmail.com'
    subject 'Secret Santa'
    body "Hello #{giver},\n\nYou will be buying for #{receiver}.\n\nRegards,\nSanta"
  end

end
