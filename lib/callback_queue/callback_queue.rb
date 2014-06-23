require 'drb/drb'
require 'thread'

class CallbackQueue
  def initialize
    @queue = Queue.new
  end
  
  def classes
    return [Object]
  end

  def verify!(obj)
    if classes.none? { |klass| obj.class == klass }
      raise(TypeError, "#{obj.class.name} is not of any #{classes.inspect}")
    end
  end

  # The user is expected to subclass the CallbackQueue class and implement
  # this method.
  def receive(obj)
    raise NotImplementedError
  end

  def start_service!(uri)
    DRb.start_service(uri, @queue)
    $stderr.puts("#{self.class} listening on #{DRb.uri}")

    trap("INT") do
      $stderr.puts("Stopping server...")
      exit 0
    end

    loop do
      begin
        # Get the next object in the queue and do stuff with it. If the
        # queue is empty, we will wait until something is put inside it.
        obj = @queue.deq
        receive(obj)
      rescue TypeError => err
        $stderr.puts("!! #{err.class.name}: #{err.message}")
      end
    end
  end
end
