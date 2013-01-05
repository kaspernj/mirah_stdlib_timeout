package org.kaspernj.mirah.stdlib.timeout

import org.junit.Test

class TestTimeout
  $Test
  def testSimpleCall
    puts "testSimpleCall"
    
    called = false
    Timeout.timeout(5.0) do
      Thread.sleep(500)
      called = true
      return nil
    end
    
    raise "Expected timeout to actually call stuff." if !called
    return
  end
  
  $Test
  def testTimeout
    puts "testTimeout"
    called = false
    
    begin
      Timeout.timeout(0.5) do
        Thread.sleep(1000)
        called = true
        return nil
      end
      
      raise "Didnt expect this to actually happen."
    rescue TimeoutError
      #This is expected.
    end
    
    raise "Didnt expect the call to actually be made but it was: #{called}." if called
    return
  end
  
  $Test
  def testReturnValue
    puts "testReturnValue"
    
    res = Timeout.timeout(0.5) do
      Thread.sleep(100)
      return "test"
    end
    
    raise "Got null: #{res}" if res == nil
    raise "Expected string return but got: '#{res.getClass.getName}'." if !res.getClass.getSimpleName.equals("String")
    raise "Expected 'test' content but got: '#{res}'." if !res.equals("test")
    
    return
  end
  
  $Test
  def testCustomErrors
    puts "testStubbornThread"
    
    begin
      Timeout.timeout(0.5, MyWeirdError.class) do
        run = true
        
        while run
          begin
            Thread.sleep(2000)
          rescue InterruptedException
            puts "DONT WANT TO DIE!"
            #ignore - be stubborn! Dont want to die with normal interrupt!
          end
        end
      end
      
      raise "This should not happen."
    rescue MyWeirdError
      #expected
    end
    
    return
  end
end

class MyWeirdError < Throwable; end