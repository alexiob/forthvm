# defmodule ForthVM.VM do
#   alias ForthVM.VM
#   alias ForthVM.PC
#   alias ForthVM.Stack
#   # alias ForthVM.Memory
#   alias ForthVM.Dictionary
#   alias ForthVM.Tokenizer

#   @main_word "main"

#   defstruct stack: %Stack{},
#     return_stack: %Stack{},
#     # memory: %Memory{},
#     dictionary: nil,
#     # program: nil,
#     pc: %PC{},
#     reductions: 0,
#     status: nil

#   def new(_memory_size \\ 10000) do
#     %VM{
#       stack: Stack.new(),
#       return_stack: Stack.new(),
#       # memory: Memory.new(memory_size),
#       dictionary: Dictionary.new(),
#       # program: A.Vector.new([]),
#       pc: nil,
#       reductions: 0,
#       status: :exec
#     }
#   end

#   def load(vm = %VM{}, source, source_id) when is_binary(source) do
#     load(vm, A.Vector.new(Tokenizer.parse(source, source_id)))
#   end

#   def load(vm = %VM{}, tokens) do
#     dictionary = Dictionary.add(vm.dictionary, @main_word, tokens)
#     pc = PC.new(dictionary[@main_word])

#     %{vm | dictionary: dictionary, last_word_name: @main_word, pc: pc}
#   end

#   # def load(vm = %VM{}, source) when is_binary(source) do
#   #   load(vm, A.Vector.new(Tokenizer.parse(source, :inline)))
#   # end

#   # def load(vm = %VM{}, tokens) do
#   #   %{vm | program: A.Vector.new(tokens), pc: 0, reductions: 0}
#   # end

#   def get_token(vm = %VM{}) do
#     PC.get(vm.pc)
#   end

#   # def get_token(vm = %VM{}, pc = %PC{}) do
#   #   A.Vector.fetch!(vm.program, pc)
#   # end

#   # def get_token(vm = %VM{}, pc) when is_integer(pc) do
#   #   A.Vector.fetch!(vm.program, pc)
#   # end

#   # def get_next_token(vm = %VM{pc: pc}) do
#   #   get_token(vm, pc + 1)
#   # end

#   def inc_pc(vm = %VM{pc: pc}) do
#     %{vm | pc: PC.inc(pc)}
#   end

#   def set_pc(vm = %VM{pc: pc}, idx) do
#     %{vm | pc: PC.set(pc, idx)}
#   end

#   def has_word?(vm = %VM{}, name) when is_binary(name) do
#     Map.has_key?(vm.dictionary, name)
#   end

#   def get_word(vm = %VM{}, name) when is_binary(name) do
#     Map.get(vm.dictionary, name)
#   end

#   def push(vm = %VM{stack: stack}, value) do
#     %{vm | stack: Stack.push(stack, value)}
#   end

#   def pop(vm = %VM{stack: stack}) do
#     {value, stack} = Stack.pop(stack)

#     {%{vm | stack: Stack.pop(stack)}, value}
#   end

#   def c_push(vm = %VM{return_stack: stack}, value) do
#     %{vm | return_stack: Stack.push(stack, value)}
#   end

#   def c_pop(vm = %VM{return_stack: stack}) do
#     {value, stack} = Stack.pop(stack)

#     {%{vm | return_stack: stack }, value}
#   end
# end
