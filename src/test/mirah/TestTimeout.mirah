package org.kaspernj.mirah.stdlib.timeout

import org.junit.Test
import org.kaspernj.mirah.stdlib.core.TestClass

$TestClass
class TestTimeout
  $Test
  def testTimeout
    called = false
    Timeout.timeout(5.0) do
      Thread.sleep(500)
      called = true
    end
    
    raise "Expected timeout to actually call stuff." if !called
    
    called = false
    
    begin
      Timeout.timeout(0.5) do
        Thread.sleep(1000)
        called = true
      end
      
      raise "Didnt expect this to actually happen."
    rescue TimeoutError
      #This is expected.
    end
    
    raise "Didnt expect the call to actually be made but it was: #{called}." if called
    
    return
  end
end