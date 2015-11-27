require 'optparse'
require 'mail'

OptionParser.new do |opts|
  opts.banner = "Usage: secret_santa.rb [options]"
  opts.on("-m", "--mailhost MAILHOST", "Mailhost") do |m|
    @mailhost = m
  end
  opts.on("-f", "--from EMAILADDRESS", "From Email Address") do |e|
    @from_email = e
  end
  opts.on("-d", "--data FILE", "Data File") do |f|
    @data_file = f
  end
  opts.on("-u", "--username USERNAME", "GMail Username") do |u|
    @username = u
  end
  opts.on("-p", "--password PASSWORD", "GMail Password") do |p|
    @password = p
  end
  opts.on("-h", "--domain", "Sending domain") do |d|
    @domain = d
  end
end.parse!

mail_options = {
  address: 'smtp.gmail.com',
  port: 587,
  domain: 'gmail.com',
  user_name: @username,
  password: @password,
  authentication: 'login',
  enable_starttls_auto: true,
  domain: @domain
}

Mail.defaults do
  delivery_method :smtp, mail_options
end

emails = {}
@family = []
File.readlines(@data_file).each do |line|
  name, email = line.split('|')
  @family << name
  emails[name] = email
end

def reset!
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

from_email = @from_email
@buyers.each do |giver, receiver|
  mail = Mail.new do
    to emails[giver]
    from from_email
    subject 'Secret Santa'
    body "Hello #{giver},\n\nYou will be giving a present to #{receiver}.\n\nBest wishes,\nSanta"
  end
  mail.deliver!
end
