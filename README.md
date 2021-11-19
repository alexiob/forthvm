# ForthVM: a toy

[![Build Status](https://travis-ci.com/alexiob/forthvm.svg?branch=master)](https://travis-ci.com/alexiob/forthvm)
[![Hex version](https://img.shields.io/hexpm/v/forthvm.svg)](https://hex.pm/packages/forthvm)
[![Coverage Status](https://coveralls.io/repos/github/alexiob/forthvm/badge.svg?branch=master)](https://coveralls.io/github/alexiob/forthvm?branch=master)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/forthvm.svg)](https://hex.pm/packages/forthvm)

Very simple Forth-like VM/Interpreter written in Elixir.

I have written it to experiment implementing a stack-based preemtive multitasking interpreter (and to play) with Elixir.

## Points of interest

- ForthVM supports quoted strings like `"hello world" .`.
- ForthVM supports multiple concurrent isolated cores (Elixir processes) running concurrent Forth processes.
- ForthVM processes inside the same core can send messages to other processes and trigger execution of any defined word.
- ForthVM captures stdio and send corresponding messages to all registered processes (example, for UI stuff).

## Supervisor structure

```txt
ForthVM
|- ForthVM.Supervisor: top-level supervisor. Only one of this can be started.
  |- ForthVM.Registry: used to keep tab of core workers.
  |- ForthVM.Subscriptions: used to subscribe to ForthVM events, like those from IOCapture.
  |- ForthVM.IOCapture: collects all ForthVM outputs and dispatches to registered processes.
  |- ForthVM.IOLogger: simple logger receiving messages from IOCapture.
  |- ForthVM.Core.Supervisor: spawns Core workers, one for each Core.
    |- ForthVM.Core.Worker: run ForthVM processes. Can spawn as many new processes as needed.
    |- ...
```

## Usage

The easiest way to play with it is to use the very bearbones REPL:

```sh
mix repl
```

And inside it:

```txt
ForthVM REPL (v0.5.0)
>> 22 22 +
>> .
44
>> .s
>> s.
>> dictionary
Dictionary ([w] = word, [v] = variable, [c] = constant):
[w] !               ( x name -- ) - store value in variable
[w] &               ( x y -- v ) - bitwise and
[w] (               ( -- ) - discard all tokens till ")" is fountd
[w] *               ( x y -- n ) - multiplies x by y
[w] **              ( x y -- n ) - calculates pow of x by y
[w] */              ( x -- n ) - perform multiplication and divide result by x
[w] +               ( y x -- n ) - sums y to x
[w] +!              ( x name -- ) - increment variable by given value
[w] +loop           ( inc -- ) - keep processing do_tokens till count < end_count, incrementing count by top value on the data stack
[w] -               ( y x -- n ) - subtracts y from x
[w] -rot            ( x y z -- z x y ) - rotate the top three stack entries, top goes on bottom
[w] .               ( x -- ) - pops and prints the literal value on the top of the data_stack
[w] .s              ( -- ) - prints the whole data_stack, without touching it
[w] /               ( x y -- n ) - divides x by y
[w] /mod            ( x y -- rem div ) - divides x by y, places divident and reminder on top of data stack
[w] 0<              ( x -- bool ) - check if value is less than zero
[w] 0=              ( x -- bool ) - check value is euqal to 0
[w] 0>              ( x -- bool ) - check if value is greater than zero
[w] 1+              ( x -- n ) - adds 1 to x
[w] 1-              ( x -- n ) - subtracts 1 to x
[w] 2drop           ( x y -- ) - remove two elements from top of stack
[w] 2dup            ( x y -- x y x y ) - duplicate two elements from top of stack
[w] 2over           ( y2 x2 y1 x1 -- y2 x2 y1 x1 y2 x2) - swap top copules on top of stack
[w] 2swap           ( y2 x2 y1 x1 -- y1 x1 y2 x2 ) - swap top copules on top of stack
[w] :               ( -- ) - convert all tokens till ";" is found into a new word
[w] <               ( x y -- bool ) - check if x is less than y
[w] <<              ( x y -- v ) - bitwise shift left
[w] <=              ( x y -- bool ) - check if x is less than or equal to y
[w] <>              ( x y -- bool ) - check two values are different. Works on different types
[w] =               ( x y -- bool ) - check two values are equal. Works on different types
[w] >               ( x y -- bool ) - check if x is greater than y
[w] >=              ( x y -- bool ) - check if x is greater than or equal to y
[w] >>              ( x y -- v ) - bitwise shift right
[w] >r              ( data -- ) - move the top of the data stack to the return stack
[w] ?               ( var -- ) - fetch a variable value and prints it
[w] ?dup            ( x -- x x ) - duplicate element from top of stack if element value is truthly
[w] @               ( name -- ) - get value in variable
[w] @-              ( x -- n ) - negates x
[w] ^               ( x y -- v ) - bitwise xor
[w] abort           ( i * x -- ) - ( R: j * x -- ) empty the data stack and perform the function of QUIT, which includes emptying the return stack, without displaying a message.
[w] abort?          ( flag i * x -- ) - ( R: j * x -- ) if flag is truthly empty the data stack and perform the function of QUIT, which includes emptying the return stack, displaying a message.
[w] abs             ( x -- n ) - absolute of x
[w] and             ( x y -- bool ) - logical and
[w] begin           ( -- ) - start loop declaration
[w] constant        ( x -- ) - create a new costant with name from next token and value from data stack
[w] cos             ( x -- n ) - cos of x
[w] cr              ( -- ) - emits a carriage return
[w] debug-disable   ( -- ) - set process debug flag to false.
[w] debug-dump-word ( -- ) - prints the definition of the word specified in the next token.
[w] debug-enable    ( -- ) - set process debug flag to true.
[w] depth           ( -- x ) - get stack depth
[w] dictionary      ( -- ) - ( -- ) print list of words in dictionary
[w] do              ( end_count count -- ) - start loop declaration
[w] drop            ( x -- ) - remove element from top of stack
[w] dup             ( x -- x x ) - duplicate element from top of stack
[w] emit            ( c -- ) - pops and prints (without cr) the binary of an ascii value on the top of the data_stack
[w] end             ( -- ) - ( R: -- ) explicit process termination
[w] exit            ( -- ) - ( -- ) explicit VM termination
[w] false           ( -- bool ) - the false constant
[w] help            ( -- ) - ( -- ) print description of dictionary's word/var/const specified as the next token
[w] i               ( -- count ) - copy the top of a LOOP's return stack to the data stack
[w] if/else/than    ( x -- ) - if x is truthly execute words before than, if falsly and else is specified, execute code before else
[w] include         ( -- ) - include program file from filename specified in next token.
[w] inspect         ( x -- ) - pops and prints the inspected value on the top of the data_stack
[w] j               ( -- data ) - copy data from return stack after LOOP's definition to the data stack
[w] l[              ( x y z -- l ) - collect all tokens till ] is found and store on the data stack as a list
[w] loop            ( -- ) - keep processing do_tokens till count < end_count, each step incrementing count by 1
[w] max             ( x y -- n ) - miaximum between two values
[w] min             ( x y -- n ) - minimum between two values
[w] not             ( x -- bool ) - logical not
[w] or              ( x y -- bool ) - logical or
[w] over            (y x -- y x y) - copy second element on top of stack
[w] pi              ( -- n ) - puts Pi value on top of stack
[w] puts            ( x -- ) - pops and prints the literal value on the top of the data_stack
[w] r>              ( -- data ) - move the top of the return stack to the data stack
[w] r@              ( -- data ) - copy the top of the return stack to the data stack
[w] rand            ( -- n ) - puts random number on stack
[w] rot             ( x y z -- y z x ) - rotate the top three stack entries, bottom goes on top
[w] send            (message_data cnt ":"word process_id -- ) - ( -- ) sends a message to a process inside the current core. The message is handled by a word with same name minus the ":" prefix. Cnt is the number elements in the data stack to be included in the message.
[w] set-io-device   ( name -- ) - set the current IO device to the value on the top of the data_stack
[w] sin             ( x -- n ) - sin of x
[w] sleep           ( x -- ) - sleep for given milliseconds
[w] sqrt            ( x -- n ) - sqrt of x
[w] swap            ( x y -- y x ) - swap top two elements on top of stack
[w] tan             ( x -- n ) - tan of x
[w] true            ( -- bool ) - the true constant
[w] until           (bool -- ) - keep processing untill contition is truthly
[w] variable        ( -- ) - create a new variable with name from next token
[w] |               ( x y -- v ) - bitwise or
[w] ~               ( x -- v ) - bitwise not
```

## TODO:

- [x] tokenizer
- [x] interpreter
- [x] core words
- [x] loops
- [x] if-then-else
- [x] include
- [x] REPL
- [x] sleep word
- [x] list type definition
- [x] VM
- [x] multiple Forth processes running in a single VM
- [x] process messages: sending messages to a process will call a matching word
- [ ] step-by-step debugger
- [ ] real Forth: define and handled immediate words

## License

ForthVM is provided under the [MIT license](LICENSE)
