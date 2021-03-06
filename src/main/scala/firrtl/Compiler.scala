/*
Copyright (c) 2014 - 2016 The Regents of the University of
California (Regents). All Rights Reserved.  Redistribution and use in
source and binary forms, with or without modification, are permitted
provided that the following conditions are met:
   * Redistributions of source code must retain the above
     copyright notice, this list of conditions and the following
     two paragraphs of disclaimer.
   * Redistributions in binary form must reproduce the above
     copyright notice, this list of conditions and the following
     two paragraphs of disclaimer in the documentation and/or other materials
     provided with the distribution.
   * Neither the name of the Regents nor the names of its contributors
     may be used to endorse or promote products derived from this
     software without specific prior written permission.
IN NO EVENT SHALL REGENTS BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS,
ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
REGENTS HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
REGENTS SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF
ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". REGENTS HAS NO OBLIGATION
TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
MODIFICATIONS.
*/

package firrtl

import com.typesafe.scalalogging.LazyLogging
import java.io.Writer

import Utils._
import firrtl.passes._

trait Compiler extends LazyLogging {
  def run(c: Circuit, w: Writer)
}

object FIRRTLCompiler extends Compiler {
  def run(c: Circuit, w: Writer) = {
    FIRRTLEmitter.run(c, w)
    w.close
  }
}

object VerilogCompiler extends Compiler {
  // Copied from Stanza implementation
  val passes = Seq(
    //CheckHighForm,          
    //FromCHIRRTL,
    CInferTypes,
    CInferMDir,
    RemoveCHIRRTL,
    ToWorkingIR,            
    CheckHighForm,
    ResolveKinds,
    InferTypes,
    CheckTypes,
    ResolveGenders,
    CheckGenders,
    InferWidths,
    CheckWidths,
    PullMuxes,
    ExpandConnects,
    RemoveAccesses,
    ExpandWhens,
    CheckInitialization,   
    ConstProp,
    ResolveKinds,
    InferTypes,
    ResolveGenders,
    InferWidths,
    LowerTypes,
    ResolveKinds,
    InferTypes,
    ResolveGenders,
    InferWidths,
    VerilogWrap,
    SplitExp,
    VerilogRename
  )
  def run(c: Circuit, w: Writer)
  {
    val loweredIR = PassUtils.executePasses(c, passes)
    VerilogEmitter.run(loweredIR, w)
    w.close
  }

}
