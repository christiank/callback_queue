$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'callback_queue/callback_queue'

class TheaterGoer
  attr_writer :ticket

  def initialize
    @ticket = nil
  end

  def has_ticket?
    return @ticket
  end
end

class Juvenile < TheaterGoer
end

class TheaterQueue < CallbackQueue
  def classes
    return [TheaterGoer, Juvenile]
  end

  def receive(theater_goer)
    verify!(theater_goer)
    if theater_goer.has_ticket?
      if theater_goer.is_a?(Juvenile)
        puts "#{theater_goer.inspect} is too young to see the show. No entry."
      else
        puts "#{theater_goer.inspect} is allowed to see the show."
      end
    else
      puts "#{theater_goer.inspect} has no ticket. No entry."
    end
  end
end

#####

if $0 == __FILE__
  q = TheaterQueue.new
  q.start_service!("druby://:12345")
end
