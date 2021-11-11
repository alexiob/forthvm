# ForthVM

Very simple Forth-like VM/Interpreter written in Elixir

## Structure

ForthVM
|- ForthVM.Supervisor
  |- ForthVM.Registry: used to keep tab of core workers
  |- ForthVM.Subscriptions: used to subscribe to ForthVM events, like those from IOCapture
  |- ForthVM.IOCapture: collects all ForthVM outputs and dispatches to registered processes
  |- ForthVM.IOLogger: simple logger receiving messages from IOCapture
  |- ForthVM.Core.Supervisor: spawns Core workers
    |- ForthVM.Core.Worker: run ForthVM processes
    |- ...

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

