# The Terrible Timeout

### by Marc Schwieterman

---

# Overview

* Why `Timeout` is a problem
* What you can do about it
* Where you may see `Timeout`

---

# Timeout is Unsafe

> Ruby's Thread#raise, Thread#kill, and the timeout.rb standard library based on them are inherently broken and should not be used for any purpose.
-- Charles Nutter, 2008[^1]

[^1]: http://blog.headius.com/2008/02/ruby-threadraise-threadkill-timeoutrb.html

^ Java and other languages have deprecated and removed thread interrupt features

^ There have been improvements in ruby since then, but...

---

# Timeout is *Still* Unsafe

> In the last 3 months, I’ve worked with a half dozen Sidekiq users plagued with mysterious stability problems. All were caused by the same thing: Ruby’s terrible Timeout module. I strongly urge everyone reading this to remove any usage of Timeout from your codebase.
-- Mike Perham, 2015[^2]

[^2]: http://www.mikeperham.com/2015/05/08/timeout-rubys-most-dangerous-api/

^ Unable to make `connection_pool` safe

---

# Happy Path

``` ruby
Timeout.timeout(1) do
  # do something
end
```

^ You have very little control over what happens in the block.

---

# The Problem[^3]

``` ruby
main = Thread.current
timer = Thread.start {
  begin
    sleep sec
    main.raise Timeout::Error
  end
}
return yield
timer.kill
```

[^3]: https://github.com/ruby/ruby/blob/v2_0_0_645/lib/timeout.rb

---

# Rescue[^4]

``` ruby
Timeout.timeout(0.001) do
  begin
    raise
  rescue
    sleep 0.002
    # will code here execute?
  end
end
```

[^4]: https://github.com/marcisme/talks/blob/master/TTT/timeout_test.rb

---

# NO

---

# Ensure[^5]

``` ruby
Timeout.timeout(0.001) do
  begin
  ensure
    sleep 0.002
    # will code here execute?
  end
end
```

[^5]: https://github.com/marcisme/talks/blob/master/TTT/timeout_test.rb

---

# NO

---

# Synchronization is Not Atomicity

`ActiveRecord::Base.connection`[^6]

``` ruby
def checkout
  synchronize do
    conn = acquire_connection # ConnectionTimeoutError
    conn.lease
    checkout_and_verify(conn) # select 1
  end
end
```

[^6]: https://github.com/rails/rails/blob/v4.1.14.2/activerecord/lib/active_record/connection_adapters/abstract/connection_pool.rb

^ `acquire_connection` can raise ConnectionTimeoutError

^ `conn.lease` sets state on that connection object

^ `checkout_and_verify` can query the database, which may have its own timeout value

---

# Thread.handle_interrupt[^7]

* `:immediate` - Invoke interrupts immediately
* `:on_blocking` - Invoke interrupts while BlockingOperation
* `:never` - Never invoke all interrupts

[^7]: http://ruby-doc.org/core-2.0.0/Thread.html#method-c-handle_interrupt

^ Threads push interrupts through a queue, and `handle_interrupt` controls when the receiving thread processes the event.

---

# Thread.handle_interrupt[^8]

``` ruby
Timeout.timeout(0.001) do
  Thread.handle_interrupt(Timeout::Error => :never) do
    begin
    ensure
      sleep 0.002
      # will code here execute?
    end
  end
end
```

[^8]: https://github.com/marcisme/talks/blob/master/TTT/timeout_test.rb

---

# Probably. But...

^ Probably not in 2.0

---

# Thread.handle_interrupt

``` ruby
Timeout.timeout(0.001) do
  Thread.handle_interrupt(Timeout::Error => :never) do
    begin
      Thread.handle_interrupt(TolerableError => :immediate) do
        # do something that can be safely interrupted
      end
    ensure
      # code here will execute
    end
  end
end
```

^ sidekiq guy and ruby docs both advise against

---

# Where

* Application code - Search for "Timeout.timeout"
* pinglish[^9]
* ~~Net::HTTP~~ ???

[^9]: https://github.com/jbarnette/pinglish/blob/b546053/lib/pinglish.rb#L127-L129

^ I've seen AR pool get leak on nothing but back to back pinglish checks

^ There are still a coupe uses of timeout in Net::HTTP, but they seem "safish"

^ `IO.select` and native network timeouts should be safe???

---

# Marc Schwieterman

* [@mschwieterman](https://twitter.com/mschwieterman)
* [marcschwieterman.com](http://marcschwieterman.com)
* [github.com/marcisme/talks/tree/master/TTT](https://github.com/marcisme/talks/tree/master/TTT)

