package org.kaspernj.mirah.stdlib.timeout

class Timeout
  def do_timeout(seconds:double, error:Class, blk:TimeoutBlock):Object
    thread_cur = Thread.currentThread
    instance = self
    sleeptime = Math.round(seconds * 1000.0)
    @done = false
    
    if error == nil
      expect_interrupt = true
    else
      expect_interrupt = false
    end
    
    thread_chk = Thread.new do
      begin
        Thread.sleep(sleeptime)
        
        if !instance.isDone
          if error == nil
            #No custom error have been given - just try to interrupt the running thread normally.
            thread_cur.interrupt if !instance.isDone
          else
            #Custom error has been given - make instance and try to stop the thread with that.
            error_obj = Throwable(error.newInstance)
            thread_cur.stop(error_obj)
          end
        end
      rescue InterruptedException
        #Ignore - block was done running before wait was reached and the check-thread was interrupted to not use resources.
      end
    end
    
    thread_chk.start
    
    #Ensure-bug in Mirah forces a lot of exception-stuff :-(
    res = nil
    
    begin
      begin
        res = blk.run
      ensure
        @done = true
      end
      
      thread_chk.interrupt if thread_chk.isAlive
    rescue InterruptedException => e
      if expect_interrupt
        raise TimeoutError.new
      else
        raise e
      end
    end
    
    return res
  end
  
  def isDone
    return @done
  end
  
  def self.timeout(seconds:double, blk:TimeoutBlock):Object
    return Timeout.new.do_timeout(seconds, nil, blk)
  end
  
  def self.timeout(seconds:double, error:Class = nil, blk:TimeoutBlock = nil):Object
    return Timeout.new.do_timeout(seconds, error, blk)
  end
  
  interface TimeoutBlock do
    def run:Object; end
  end
end

#This error is being thrown, when a timeout is reached and block is not done running.
class TimeoutError < InterruptedException; end