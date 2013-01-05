package org.kaspernj.mirah.stdlib.timeout

class Timeout
  def do_timeout(seconds:double, blk:Runnable):void
    thread_cur = Thread.currentThread
    instance = self
    sleeptime = Math.round(seconds * 1000.0)
    @done = false
    
    thread_chk = Thread.new do
      begin
        puts "Sleeping for milisecs: #{sleeptime}"
        Thread.sleep(sleeptime)
        thread_cur.interrupt if !instance.isDone
      rescue InterruptedException
        #Ignore - block was done running before wait was reached.
      end
    end
    
    thread_chk.start
    
    begin
      blk.run
      thread_chk.interrupt if thread_chk.isAlive
      @done = true
    rescue InterruptedException
      raise TimeoutError.new
    end
    
    return
  end
  
  def isDone
    return @done
  end
  
  def self.timeout(seconds:double, blk:Runnable):void
    Timeout.new.do_timeout(seconds, blk)
    return
  end
end

#This error is being thrown, when a timeout is reached and block is not done running.
class TimeoutError < InterruptedException; end