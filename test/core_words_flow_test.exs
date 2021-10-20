defmodule ForthVM.ProcessWordFlowTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO
  import TestHelpers

  test "<CONDITION> if <CODE> else <CODE> then" do
    assert {:exit, _, 42} = core_run(~s[1 2 < if 42 else 43 then])
    assert {:exit, _, 42} = core_run(~s[2 1 > if 42 else 43 then])
  end

  test "nested <CONDITION> if <CODE> else <CODE> then" do
    assert {:exit, _, 1} = core_run(~s[ 5 dup 3 < if 10 else 7 < if 1 else 5 then then ])
  end

  test "<CONDITION> if <CODE> then" do
    assert {:exit, _, 42} = core_run(~s[ 1 2 < if 42 then ])
  end

  test "divide by zero checker" do
    assert capture_io(fn -> core_run(~s[
    ( numerator denominator -- quotient )
    : /check dup 0= if "invalid" puts drop else / then ;
    5 0 /check
    25 5 /check
    .
    ]) end) == "invalid\n5.0"
  end

  test "eggsize computation with nested if" do
    assert capture_io(fn -> core_run(~s[
      : eggsize
      dup 18 < if "reject" .      else
      dup 21 < if "small" .       else
      dup 24 < if "medium" .      else
      dup 27 < if "large" .       else
      dup 30 < if "extra large" . else
                   "error" .
      then then then then then drop ;
      29 eggsize
    ]) end) == "extra large"
  end

  test "+loop" do
    assert capture_io(fn ->
             core_run(~s[ : loop-test 50 0 do i . " " . 5 +loop ; loop-test ])
           end) == "0 5 10 15 20 25 30 35 40 45 "
  end

  test "emit looped numbers" do
    assert capture_io(fn ->
             core_run(~s[ 10 0 do i emit loop ])
           end) == <<0, 1, 2, 3, 4, 5, 6, 7, 8, 9>>
  end

  test "print looped numbers" do
    assert capture_io(fn ->
             core_run(~s[ 10 0 do i . " " . loop ])
           end) == "0 1 2 3 4 5 6 7 8 9 "
  end

  test "print stack (peek)" do
    assert capture_io(fn ->
             core_run(~s[ 1 2 3 rot .s ])
           end) == "2 3 1 "
  end

  test "print stars" do
    assert capture_io(fn ->
             core_run(~s[
        : star 42 emit ;
        : stars 0 do star loop ;
        20 stars end
      ])
           end) == "********************"
  end

  test "do loop test with i" do
    assert capture_io(fn ->
             core_run(~s[
        5 0 do i . " " . loop
      ])
           end) == "0 1 2 3 4 "
  end

  test "nested loops" do
    assert capture_io(fn ->
             core_run(~s[
        : star 42 emit ;
        : dash 45 emit ;
        : stardashes 0 do 2 0 do star loop 2 0 do dash loop loop ;
        5 stardashes end
      ])
           end) == "**--**--**--**--**--"
  end

  test "looping negative numbers in a definition" do
    assert capture_io(fn ->
             core_run(~s[
        : negative-loop -243 -250 do i . " " . loop ;
        negative-loop
      ])
           end) == "-250 -249 -248 -247 -246 -245 -244 "
  end

  test "multiplication loop" do
    assert capture_io(fn ->
             core_run(~s[
        : multiplications cr 11 1 do dup i * . " " . loop drop ; 7 multiplications
      ])
           end) == "\n7 14 21 28 35 42 49 56 63 70 "
  end

  test "quadratic equation using return stack operators" do
    assert {:exit, _, 48} = core_run(~s[
      : quadratic ( a b c x -- n )
      >r swap rot r@ * + r> * + ;
      2 7 9 3 quadratic
    ])
  end

  test "temperature conversions" do
    assert {:exit, _, [-279.4, 260.77777777777777]} = core_run(~s[
      : F>C ( fahr -- cels ) 32 - 10 18 */ ;
      : C>F ( cels -- fahr ) 18 10 */ 32 + ;
      : C>K ( cels -- kelv ) 273 + ;
      : K>C ( kelv -- cels ) 273 - ;
      : F>K ( fahr -- kelv ) F>C C>K ;
      : K>F ( kelv -- fahr ) K>C C>F ;
      10 F>K 100 K>F
    ])
  end

  test "variables" do
    assert capture_io(fn -> core_run(~s[
      : ? @ . " " . ;
      variable DATE
      variable MONTH
      variable YEAR
      : !DATE YEAR ! DATE ! MONTH ! ;
      7 31 3 !DATE
      : .DATE MONTH ? DATE ? YEAR ? ;
      .DATE
    ]) end) == "7 31 3 "
  end

  test "egg counting" do
    assert capture_io(fn -> core_run(~s[
      : ? @ . ;
      variable EGGS
      12 constant DOZEN
      : RESET 0 EGGS ! ;
      : EGG 1 EGGS +! ;
      : CARTON DOZEN EGGS +! ;
      RESET
      EGG
      EGG
      CARTON
      EGG
      EGGS ?
    ]) end) == "15"
  end

  test "frozen pies" do
    assert capture_io(fn -> core_run(~s[
      : ? @ . " " . ;
      variable PIES 0 PIES !
      : BAKE-PIE 1 PIES +! ;
      : EAT-PIE PIES @
        if -1 PIES +! "Thank you" puts
        else "What pie?" puts
        then
      ;
      variable FROZEN-PIES 0 FROZEN-PIES !
      : FREEZE-PIES PIES @ FROZEN-PIES +! 0 PIES ! ;
      EAT-PIE
      BAKE-PIE
      BAKE-PIE
      BAKE-PIE
      PIES ?
      EAT-PIE
      FREEZE-PIES
      PIES ?
      FROZEN-PIES ?
    ]) end) == "What pie?\n3 Thank you\n0 2 "
  end
end
