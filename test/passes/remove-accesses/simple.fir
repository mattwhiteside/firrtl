; RUN: firrtl -i %s -o %s.v -X verilog -p c 2>&1 | tee %s.out | FileCheck %s

circuit top :
   module top :
      output o : UInt
      wire m : UInt<32>[2]
      wire i : UInt
      m[0] <= UInt("h1")
      m[1] <= UInt("h1")
      i <= UInt("h1")
      node a = m[i] 
      o <= a

;CHECK: Done!
