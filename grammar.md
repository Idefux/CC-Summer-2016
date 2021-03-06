Copyright (c) 2015-2016, the Selfie Project authors. All rights reserved. Please see the AUTHORS file for details. Use of this source code is governed by a BSD license that can be found in the LICENSE file.

Selfie is a project of the Computational Systems Group at the Department of Computer Sciences of the University of Salzburg in Austria. For further information and code please refer to:

http://selfie.cs.uni-salzburg.at

This is the grammar of the C Star (C*) programming language.

C* is a small Turing-complete subset of C that includes dereferencing (the * operator) but excludes data structures, bitwise and Boolean operators, and many other features. C* is supposed to be close to the minimum necessary for implementing a self-compiling, single-pass, recursive-descent compiler.

Keywords: int, while, if, else, return, void

```
digit            = "0" | ... | "9" .

integer          = digit { digit } .

letter           = "a" | ... | "z" | "A" | ... | "Z" .

identifier       = letter { letter | digit | "_" } .

type             = "int" [ "*" ] .

cast             = "(" type ")" .

call             = identifier "(" [ expression { "," expression } ] ")" .

literal          = integer | "'" ascii_character "'" .

factor           = [ cast ]
                    ( [ "*" ] ( identifier [ arryIndex ] [ structAccess ] |
                      "(" expression ")" ) |
                      call |
                      literal |
                      """ { ascii_character } """ ) .

term             = factor { ( "*" | "/" | "%" ) factor } .

simpleExpression = [ "-" ] term { ( "+" | "-" ) term } .

extExpression    = simpleExpression { ( "<<" | ">>" ) simpleExpression } .

expression       = extExpression [ ( "==" | "!=" | "<" | ">" | "<=" | ">=" ) extExpression ] .

while            = "while" "(" expression ")"
                             ( statement |
                               "{" { statement } "}" ) .

if               = "if" "(" expression ")"
                             ( statement |
                               "{" { statement } "}" )
                         [ "else"
                             ( statement |
                               "{" { statement } "}" ) ] .

return           = "return" [ expression ] .

statement        = ( [ "*" ] identifier [ arrayIndex ] [ structAccess ] | "*" "(" expression ")" ) "="
                      expression ";" |
                    call ";" |
                    while |
                    if |
                    return ";" .

variable         = type identifier [ arrayIndex ] [ structAccess ] .

procedure        = "(" [ variable { "," variable } ] ")"
                    ( ";" | "{" { ( variable | struct ) ";" } { statement } "}" ) .

structAccess   = "->" identifier [ arrayIndex ] [structAccess]

arrayIndex    = "[" expression "]" [ "[" expression "]" ]

struct           = "struct" identifier "{" variable ";" { variable ";" } "}" .

cstar            = { variable [ "=" [ cast ] [ "-" ] literal ] ";" |
                   ( "void" | type ) identifier procedure |
                    struct } .
```
