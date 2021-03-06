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
grammar FIRRTL;

/*------------------------------------------------------------------
 * PARSER RULES
 *------------------------------------------------------------------*/

/* TODO 
 *  - Add [info] support (all over the place)
 *  - Add support for extmodule
*/

// Does there have to be at least one module?
circuit
  : 'circuit' id ':' '{' module* '}'
  ;

module
  : 'module' id ':' '{' port* block '}'
  | 'extmodule' id ':' '{' port* '}'
  ;

port
  : dir id ':' type
  ;

dir
  : 'input'
  | 'output'
  ;

type 
  : 'UInt' ('<' IntLit '>')?
  | 'SInt' ('<' IntLit '>')?
  | 'Clock'
  | '{' field* '}'        // Bundle
  | type '[' IntLit ']'   // Vector
  ;

field
  : 'flip'? id ':' type
  ;

// Much faster than replacing block with stmt+
block
  : (stmt)*
  ; 

stmt
  : 'wire' id ':' type
  | 'reg' id ':' type exp ('with' ':' '{' 'reset' '=>' '(' exp exp ')' '}')?
  | 'mem' id ':' '{' ( 'data-type' '=>' type 
                     | 'depth' '=>' IntLit
                     | 'read-latency' '=>' IntLit
                     | 'write-latency' '=>' IntLit
                     | 'read-under-write' '=>' ruw
                     | 'reader' '=>' id
                     | 'writer' '=>' id
                     | 'readwriter' '=>' id 
                     )*
                 '}'
  | 'cmem' id ':' type
  | 'smem' id ':' type
  | mdir 'mport' id '=' id '[' exp ']' exp
  | 'inst' id 'of' id 
  | 'node' id '=' exp
  | exp '<=' exp 
  | exp '<-' exp
  | exp 'is' 'invalid'
  | 'when' exp ':' '{' block '}' ( 'else' ':' '{' block '}' )? 
  | 'stop(' exp exp IntLit ')'
  | 'printf(' exp exp StringLit (exp)* ')'
  | 'skip'
  ;

mdir
  : 'infer'
  | 'read'
  | 'write'
  | 'rdwr'
  ;

ruw
  : 'old'
  | 'new'
  | 'undefined'
  ;

exp
  : 'UInt' ('<' IntLit '>')? '(' IntLit ')' 
  | 'SInt' ('<' IntLit '>')? '(' IntLit ')' 
  | 'UBits' ('<' IntLit '>')? '(' StringLit ')'
  | 'SBits' ('<' IntLit '>')? '(' StringLit ')'
  | id    // Ref
  | exp '.' id 
  | exp '[' IntLit ']'
  | exp '[' exp ']'
  | 'mux(' exp exp exp ')'
  | 'validif(' exp exp ')'
  | primop exp* IntLit*  ')' 
  ;

id
  : Id
  | keyword
  ;

keyword
  : 'circuit'
  | 'module'
  | 'extmodule'
  | 'input'
  | 'output'
  | 'UInt'
  | 'SInt'
  | 'UBits'
  | 'SBits'
  | 'Clock'
  | 'wire'
  | 'reg'
  | 'mem'
  | 'reset'
  | 'data-type'
  | 'depth'
  | 'read-latency'
  | 'write-latency'
  | 'read-under-write'
  | 'reader'
  | 'writer'
  | 'readwriter'
  | 'inst'
  | 'node'
  | 'is'
  | 'invalid'
  | 'when'
  | 'else'
  | 'stop'
  | 'printf'
  | 'skip'
  | 'old'
  | 'new'
  | 'undefined'
  | 'mux'
  | 'validif'
  | 'write'
  | 'with'
  | 'read'
  | 'rdwr'
  | 'infer'
  ;

// Parentheses are added as part of name because semantics require no space between primop and open parentheses
// (And ANTLR either ignores whitespace or considers it everywhere)
primop
  : 'add('
  | 'sub('
  | 'mul('
  | 'div('
  | 'rem('
  | 'lt('
  | 'leq('
  | 'gt('
  | 'geq('
  | 'eq('
  | 'neq('
  | 'pad('
  | 'asUInt('
  | 'asSInt('
  | 'asClock('
  | 'shl('
  | 'shr('
  | 'dshl('
  | 'dshr('
  | 'cvt('
  | 'neg('
  | 'not('
  | 'and('
  | 'or('
  | 'xor('
  | 'andr('
  | 'orr('
  | 'xorr('
  | 'cat('
  | 'bits('
  | 'head('
  | 'tail('
  ;

/*------------------------------------------------------------------
 * LEXER RULES
 *------------------------------------------------------------------*/

IntLit
  : '0'
  | ( '+' | '-' )? [1-9] ( Digit )*
  | '"' 'h' ( HexDigit )+ '"'
  ;

fragment
Nondigit
  : [a-zA-Z_]
  ;

fragment
Digit
  : [0-9]
  ;

fragment
HexDigit
  : [a-fA-F0-9]
  ;

StringLit
  : '"' .*? '"'
  ;


Id
  : IdNondigit
    ( IdNondigit
    | Digit
    )*
  ;

fragment
IdNondigit
  : Nondigit
  | [~!@#$%^*\-+=?/]
  ;

Comment
  : ';' ~[\r\n]* 
    -> skip
  ;

Whitespace
  : [ \t,]+
    -> skip
  ;

Newline 
  : ( '\r'? '\n' )+
      -> skip
  ;


