-module(opcodes).
-export([asm/1,is_terminal_op/1]).

-include("os.hrl").

asm({'move',{r,X},{r,Y}}) -> [?xuuu(Y, X, 0)];
asm({'move',{s,X},{r,Y}}) when X =< 65535, X >= 0 -> [?uddu(Y, X, 1)];
asm({'move',{s,X},{r,Y}}) -> [?xxuu(Y, 2), X];
asm({'move',{r,X},{s,Y}}) when Y =< 65535, Y >= 0 -> [?dduu(Y, X, 3)];
asm({'move',{r,X},{s,Y}}) -> [?xxuu(X, 4), Y];
asm({'swap',{r,X},{r,Y}}) -> [?xuuu(Y, X, 5)];
asm({'swap',{r,X},{s,Y}}) when Y =< 65535, Y >= 0 -> [?dduu(Y, X, 6)];
asm({'swap',{r,X},{s,Y}}) -> [?xxuu(X, 7), Y];
asm({'set',{r,X},{literal,Y}}) when is_integer(Y), Y =< 32767, Y >= -32768 -> [?dduu(Y, X, 8)];
asm({'set',{r,X},{atom,Y}}) -> [?xuuu(Y, X, 9)];
asm({'set',{r,X},{literal,Y}}) -> [?xxuu(X, 10), {literal,Y}];
asm({'add',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 11)];
asm({'add',{r,X},{r,Y},{literal,Z}}) when is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 12)];
asm({'add',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 13), {literal,Z}];
asm({'mult',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 14)];
asm({'mult',{r,X},{r,Y},{literal,Z}}) when is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 15)];
asm({'mult',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 16), {literal,Z}];
asm({'sub',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 17)];
asm({'sub',{r,X},{r,Y},{literal,Z}}) when is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 18)];
asm({'sub',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 19), {literal,Z}];
asm({'sub',{r,X},{literal,Y},{r,Z}}) when is_integer(Y), Y =< 127, Y >= -128 -> [?uuuu(Z, Y, X, 20)];
asm({'sub',{r,X},{literal,Y},{r,Z}}) -> [?xuuu(Z, X, 21), {literal,Y}];
asm({'div',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 22)];
asm({'idiv',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 23)];
asm({'mod',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 24)];
asm({'neg',{r,X},{r,Y}}) -> [?xuuu(Y, X, 25)];
asm({'bnot',{r,X},{r,Y}}) -> [?xuuu(Y, X, 26)];
asm({'not',{r,X},{r,Y}}) -> [?xuuu(Y, X, 27)];
asm({'band',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 28)];
asm({'band',{r,X},{r,Y},{literal,Z}}) when is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 29)];
asm({'band',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 30), {literal,Z}];
asm({'and',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 31)];
asm({'bor',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 32)];
asm({'bor',{r,X},{r,Y},{literal,Z}}) when is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 33)];
asm({'bor',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 34), {literal,Z}];
asm({'or',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 35)];
asm({'bxor',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 36)];
asm({'bxor',{r,X},{r,Y},{literal,Z}}) when is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 37)];
asm({'bxor',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 38), {literal,Z}];
asm({'xor',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 39)];
asm({'bsl',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 40)];
asm({'bsr',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 41)];
asm({'abs',{r,X},{r,Y}}) -> [?xuuu(Y, X, 42)];
asm({'trunc',{r,X},{r,Y}}) -> [?xuuu(Y, X, 43)];
asm({'round',{r,X},{r,Y}}) -> [?xuuu(Y, X, 44)];
asm({'float',{r,X},{r,Y}}) -> [?xuuu(Y, X, 45)];
asm({'is_atom',{r,X},{l,Y}}) -> [?xxuu(X, 46), {l,Y}];
asm({'is_binary',{r,X},{l,Y}}) -> [?xxuu(X, 47), {l,Y}];
asm({'is_float',{r,X},{l,Y}}) -> [?xxuu(X, 48), {l,Y}];
asm({'is_function',{r,X},{l,Y}}) -> [?xxuu(X, 49), {l,Y}];
asm({'is_function',{r,X},Y,{l,Z}}) when Y =< 255, Y >= 0 -> [?xuuu(Y, X, 50), {l,Z}];
asm({'is_integer',{r,X},{l,Y}}) -> [?xxuu(X, 51), {l,Y}];
asm({'is_list',{r,X},{l,Y}}) -> [?xxuu(X, 52), {l,Y}];
asm({'is_cons',{r,X},{l,Y}}) -> [?xxuu(X, 53), {l,Y}];
asm({'is_nil',{r,X},{l,Y}}) -> [?xxuu(X, 54), {l,Y}];
asm({'is_not_nil',{r,X},{l,Y}}) -> [?xxuu(X, 55), {l,Y}];
asm({'is_number',{r,X},{l,Y}}) -> [?xxuu(X, 56), {l,Y}];
asm({'is_pid',{r,X},{l,Y}}) -> [?xxuu(X, 57), {l,Y}];
asm({'is_oid',{r,X},{l,Y}}) -> [?xxuu(X, 58), {l,Y}];
asm({'is_tuple',{r,X},{l,Y}}) -> [?xxuu(X, 59), {l,Y}];
asm({'is_tuple_of_arity',{r,X},{literal,Y},{l,Z}}) when Y =< 255, Y >= 0 -> [?xuuu(Y, X, 60), {l,Z}];
asm({'is_tuple_of_arity',{r,X},{literal,Y},{l,Z}}) -> [?xxuu(X, 61), {literal,Y}, {l,Z}];
asm({'is_record',{r,X},{atom,Y},{literal,Z},{l,P}}) when Z =< 255, Z >= 0 -> [?uuuu(Z, Y, X, 62), {l,P}];
asm({'is_record',{r,X},{atom,Y},{literal,Z},{l,P}}) -> [?xuuu(Y, X, 63), {literal,Z}, {l,P}];
asm({'is_record',{r,X},{literal,Y},{literal,Z},{l,P}}) when Z =< 65535, Z >= 0 -> [?dduu(Z, X, 64), {literal,Y}, {l,P}];
asm({'is_record',{r,X},{literal,Y},{literal,Z},{l,P}}) -> [?xxuu(X, 65), {literal,Y}, {literal,Z}, {l,P}];
asm({'is_atom',{r,X},{r,Y}}) -> [?xuuu(Y, X, 66)];
asm({'is_binary',{r,X},{r,Y}}) -> [?xuuu(Y, X, 67)];
asm({'is_float',{r,X},{r,Y}}) -> [?xuuu(Y, X, 68)];
asm({'is_function',{r,X},{r,Y}}) -> [?xuuu(Y, X, 69)];
asm({'is_function',{r,X},{r,Y},Z}) when Z =< 255, Z >= 0 -> [?uuuu(Z, Y, X, 70)];
asm({'is_integer',{r,X},{r,Y}}) -> [?xuuu(Y, X, 71)];
asm({'is_list',{r,X},{r,Y}}) -> [?xuuu(Y, X, 72)];
asm({'is_cons',{r,X},{r,Y}}) -> [?xuuu(Y, X, 73)];
asm({'is_nil',{r,X},{r,Y}}) -> [?xuuu(Y, X, 74)];
asm({'is_not_nil',{r,X},{r,Y}}) -> [?xuuu(Y, X, 75)];
asm({'is_number',{r,X},{r,Y}}) -> [?xuuu(Y, X, 76)];
asm({'is_pid',{r,X},{r,Y}}) -> [?xuuu(Y, X, 77)];
asm({'is_oid',{r,X},{r,Y}}) -> [?xuuu(Y, X, 78)];
asm({'is_tuple',{r,X},{r,Y}}) -> [?xuuu(Y, X, 79)];
asm({'eq',{r,X},{r,Y},{l,Z}}) -> [?xuuu(Y, X, 80), {l,Z}];
asm({'eq',{r,X},{literal,Y},{l,Z}}) when is_integer(Y), Y =< 32767, Y >= -32768 -> [?dduu(Y, X, 81), {l,Z}];
asm({'eq',{r,X},{atom,Y},{l,Z}}) -> [?xuuu(Y, X, 82), {l,Z}];
asm({'eq',{r,X},{literal,Y},{l,Z}}) -> [?xxuu(X, 83), {literal,Y}, {l,Z}];
asm({'neq',{r,X},{r,Y},{l,Z}}) -> [?xuuu(Y, X, 84), {l,Z}];
asm({'neq',{r,X},{literal,Y},{l,Z}}) when is_integer(Y), Y =< 32767, Y >= -32768 -> [?dduu(Y, X, 85), {l,Z}];
asm({'neq',{r,X},{atom,Y},{l,Z}}) -> [?xuuu(Y, X, 86), {l,Z}];
asm({'neq',{r,X},{literal,Y},{l,Z}}) -> [?xxuu(X, 87), {literal,Y}, {l,Z}];
asm({'lesseq',{r,X},{r,Y},{l,Z}}) -> [?xuuu(Y, X, 88), {l,Z}];
asm({'lesseq',{r,X},{literal,Y},{l,Z}}) when is_integer(Y), Y =< 32767, Y >= -32768 -> [?dduu(Y, X, 89), {l,Z}];
asm({'lesseq',{r,X},{atom,Y},{l,Z}}) -> [?xuuu(Y, X, 90), {l,Z}];
asm({'lesseq',{r,X},{literal,Y},{l,Z}}) -> [?xxuu(X, 91), {literal,Y}, {l,Z}];
asm({'moreeq',{r,X},{r,Y},{l,Z}}) -> [?xuuu(Y, X, 92), {l,Z}];
asm({'moreeq',{r,X},{literal,Y},{l,Z}}) when is_integer(Y), Y =< 32767, Y >= -32768 -> [?dduu(Y, X, 93), {l,Z}];
asm({'moreeq',{r,X},{atom,Y},{l,Z}}) -> [?xuuu(Y, X, 94), {l,Z}];
asm({'moreeq',{r,X},{literal,Y},{l,Z}}) -> [?xxuu(X, 95), {literal,Y}, {l,Z}];
asm({'less',{r,X},{r,Y},{l,Z}}) -> [?xuuu(Y, X, 96), {l,Z}];
asm({'less',{r,X},{literal,Y},{l,Z}}) when is_integer(Y), Y =< 32767, Y >= -32768 -> [?dduu(Y, X, 97), {l,Z}];
asm({'less',{r,X},{atom,Y},{l,Z}}) -> [?xuuu(Y, X, 98), {l,Z}];
asm({'less',{r,X},{literal,Y},{l,Z}}) -> [?xxuu(X, 99), {literal,Y}, {l,Z}];
asm({'more',{r,X},{r,Y},{l,Z}}) -> [?xuuu(Y, X, 100), {l,Z}];
asm({'more',{r,X},{literal,Y},{l,Z}}) when is_integer(Y), Y =< 32767, Y >= -32768 -> [?dduu(Y, X, 101), {l,Z}];
asm({'more',{r,X},{atom,Y},{l,Z}}) -> [?xuuu(Y, X, 102), {l,Z}];
asm({'more',{r,X},{literal,Y},{l,Z}}) -> [?xxuu(X, 103), {literal,Y}, {l,Z}];
asm({'is_true',{r,X},{l,Y}}) -> [?xxuu(X, 104), {l,Y}];
asm({'is_false',{r,X},{l,Y}}) -> [?xxuu(X, 105), {l,Y}];
asm({'eq',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 106)];
asm({'eq',{r,X},{r,Y},{literal,Z}}) when is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 107)];
asm({'eq',{r,X},{r,Y},{atom,Z}}) -> [?uuuu(Z, Y, X, 108)];
asm({'eq',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 109), {literal,Z}];
asm({'neq',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 110)];
asm({'neq',{r,X},{r,Y},{literal,Z}}) when is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 111)];
asm({'neq',{r,X},{r,Y},{atom,Z}}) -> [?uuuu(Z, Y, X, 112)];
asm({'neq',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 113), {literal,Z}];
asm({'lesseq',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 114)];
asm({'lesseq',{r,X},{r,Y},{literal,Z}}) when is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 115)];
asm({'lesseq',{r,X},{r,Y},{atom,Z}}) -> [?uuuu(Z, Y, X, 116)];
asm({'lesseq',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 117), {literal,Z}];
asm({'moreeq',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 118)];
asm({'moreeq',{r,X},{r,Y},{literal,Z}}) when is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 119)];
asm({'moreeq',{r,X},{r,Y},{atom,Z}}) -> [?uuuu(Z, Y, X, 120)];
asm({'moreeq',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 121), {literal,Z}];
asm({'less',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 122)];
asm({'less',{r,X},{r,Y},{literal,Z}}) when is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 123)];
asm({'less',{r,X},{r,Y},{atom,Z}}) -> [?uuuu(Z, Y, X, 124)];
asm({'less',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 125), {literal,Z}];
asm({'more',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 126)];
asm({'more',{r,X},{r,Y},{literal,Z}}) when is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 127)];
asm({'more',{r,X},{r,Y},{atom,Z}}) -> [?uuuu(Z, Y, X, 128)];
asm({'more',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 129), {literal,Z}];
asm({'frame',X,{literal,Y},{literal,Z}}) when X =< 255, X >= 0, Y =< 255, Y >= 0, Z =< 255, Z >= 0 -> [?uuuu(Z, Y, X, 130)];
asm({'frame',X,{literal,Y},{literal,Z}}) when X =< 255, X >= 0, Y =< 65535, Y >= 0 -> [?dduu(Y, X, 131), {literal,Z}];
asm({'frame',X,{literal,Y},{literal,Z}}) when X =< 255, X >= 0, Z =< 65535, Z >= 0 -> [?dduu(Z, X, 132), {literal,Y}];
asm({'enter',{atom,X},{atom,Y},Z}) when Z =< 255, Z >= 0 -> [?uuuu(Z, Y, X, 133)];
asm({'enter',{atom,X},{literal,Y},Z}) when Z =< 255, Z >= 0 -> [?xuuu(Z, X, 134), {literal,Y}];
asm({'enter',{literal,X},{atom,Y},Z}) when Z =< 255, Z >= 0 -> [?xuuu(Z, Y, 135), {literal,X}];
asm({'enter',{literal,X},{literal,Y},Z}) when Z =< 255, Z >= 0 -> [?xxuu(Z, 136), {literal,X}, {literal,Y}];
asm({'enter',{r,X},{r,Y},Z}) when Z =< 255, Z >= 0 -> [?uuuu(Z, Y, X, 137)];
asm({'enter',{l,X}}) -> [?xxxu(138), {l,X}];
asm({'enter_fun',X,{r,Y}}) when X =< 255, X >= 0 -> [?xuuu(Y, X, 139)];
asm({'enter_bif',X,{bif,Y}}) when X =< 255, X >= 0 -> [?xxuu(X, 140), {bif,Y}];
asm('enter_apply') -> [?xxxu(141)];
asm({'jump',{l,X}}) -> [?xxxu(142), {l,X}];
asm({'call',{atom,X},{atom,Y},Z}) when Z =< 255, Z >= 0 -> [?uuuu(Z, Y, X, 143)];
asm({'call',{atom,X},{literal,Y},Z}) when Z =< 255, Z >= 0 -> [?xuuu(Z, X, 144), {literal,Y}];
asm({'call',{literal,X},{atom,Y},Z}) when Z =< 255, Z >= 0 -> [?xuuu(Z, Y, 145), {literal,X}];
asm({'call',{literal,X},{literal,Y},Z}) when Z =< 255, Z >= 0 -> [?xxuu(Z, 146), {literal,X}, {literal,Y}];
asm({'call',{r,X},{r,Y},Z}) when Z =< 255, Z >= 0 -> [?uuuu(Z, Y, X, 147)];
asm({'call',{l,X}}) -> [?xxxu(148), {l,X}];
asm({'call_fun',X,{r,Y}}) when X =< 255, X >= 0 -> [?xuuu(Y, X, 149)];
asm({'call_bif',X,{bif,Y}}) when X =< 255, X >= 0 -> [?xxuu(X, 150), {bif,Y}];
asm('call_apply') -> [?xxxu(151)];
asm('return') -> [?xxxu(152)];
asm({'make_fun',{r,X},Y,{literal,Z},{literal,P},{r,Q}}) when Y =< 255, Y >= 0 -> [?uuuu(Q, Y, X, 153), {literal,Z}, {literal,P}];
asm({'make_fun_nil',{r,X},Y,{literal,Z},{literal,P}}) when Y =< 255, Y >= 0 -> [?xuuu(Y, X, 154), {literal,Z}, {literal,P}];
asm({'match_fail',{atom,X},{r,Y}}) -> [?xuuu(Y, X, 155)];
asm({'match_fail',{literal,X},{r,Y}}) -> [?xxuu(Y, 156), {literal,X}];
asm({'match_fail',{atom,X}}) -> [?xxuu(X, 157)];
asm({'match_fail',{literal,X}}) -> [?xxxu(158), {literal,X}];
asm({'consup',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 159)];
asm({'consup',{r,X},{atom,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 160)];
asm({'consup',{r,X},{literal,Y},{r,Z}}) when is_integer(Y), Y =< 127, Y >= -128 -> [?uuuu(Z, Y, X, 161)];
asm({'consup',{r,X},{literal,Y},{r,Z}}) -> [?xuuu(Z, X, 162), {literal,Y}];
asm({'consup',{r,X},{r,Y},{literal,Z}}) -> [?xuuu(Y, X, 163), {literal,Z}];
asm({'nil_consup',{r,X},{r,Y}}) -> [?xuuu(Y, X, 164)];
asm({'consup_nil',{r,X},{r,Y}}) -> [?xuuu(Y, X, 165)];
asm({'uncons',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 166)];
asm({'hd',{r,X},{r,Y}}) -> [?xuuu(Y, X, 167)];
asm({'tl',{r,X},{r,Y}}) -> [?xuuu(Y, X, 168)];
asm({'list_len',{r,X},{r,Y}}) -> [?xuuu(Y, X, 169)];
asm({'nil',{r,X}}) -> [?xxuu(X, 170)];
asm({'tuple',{r,X},{literal,Y}}) when Y =< 65535, Y >= 0 -> [?dduu(Y, X, 171)];
asm({'tuple',{r,X},{literal,Y}}) -> [?xxuu(X, 172), {literal,Y}];
asm({'tuple_size',{r,X},{literal,Y},{l,Z}}) when Y =< 65535, Y >= 0 -> [?dduu(Y, X, 173), {l,Z}];
asm({'tuple_size',{r,X},{literal,Y},{l,Z}}) -> [?xxuu(X, 174), {literal,Y}, {l,Z}];
asm({'tuple_size',{r,X},{r,Y}}) -> [?xuuu(Y, X, 175)];
asm({'dsetel',{r,X},{literal,Y},{r,Z}}) when Y =< 255, Y >= 0 -> [?uuuu(Z, Y, X, 176)];
asm({'dsetel',{r,X},{literal,Y},{r,Z}}) -> [?xuuu(Z, X, 177), {literal,Y}];
asm({'dsetel',{r,X},{literal,Y},{literal,Z}}) when Y =< 255, Y >= 0, is_integer(Z), Z =< 127, Z >= -128 -> [?uuuu(Z, Y, X, 178)];
asm({'dsetel',{r,X},{literal,Y},{atom,Z}}) when Y =< 255, Y >= 0 -> [?uuuu(Z, Y, X, 179)];
asm({'dsetel',{r,X},{literal,Y},{literal,Z}}) -> [?xxuu(X, 180), {literal,Y}, {literal,Z}];
asm({'dsetel_nil',{r,X},{literal,Y}}) when Y =< 65535, Y >= 0 -> [?dduu(Y, X, 181)];
asm({'dsetel_nil',{r,X},{literal,Y}}) -> [?xxuu(X, 182), {literal,Y}];
asm({'getel',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 183)];
asm({'getel',{r,X},{literal,Y},{r,Z}}) when Y =< 255, Y >= 0 -> [?uuuu(Z, Y, X, 184)];
asm({'getel',{r,X},{literal,Y},{r,Z}}) -> [?xuuu(Z, X, 185), {literal,Y}];
asm({'getel2',{r,X},{r,Y},{r,Z}}) -> [?uuuu(Z, Y, X, 186)];
asm({'gen_size',{r,X},{r,Y}}) -> [?xuuu(Y, X, 187)];
asm('recv_reset_inf') -> [?xxxu(188)];
asm({'recv_reset',{r,X}}) -> [?xxuu(X, 189)];
asm({'recv_reset',{literal,X}}) when X =< 65535, X >= 0 -> [?xddu(X, 190)];
asm({'recv_reset',{literal,X}}) -> [?xxxu(191), {literal,X}];
asm({'recv_next',{r,X},Y,{l,Z}}) when Y =< 255, Y >= 0 -> [?xuuu(Y, X, 192), {l,Z}];
asm({'recv_next',{r,X},Y}) when Y =< 255, Y >= 0 -> [?xuuu(Y, X, 193)];
asm('recv_accept') -> [?xxxu(194)];
asm({'self',{r,X}}) -> [?xxuu(X, 195)];
asm({'node',{r,X}}) -> [?xxuu(X, 196)];
asm({'node',{r,X},{r,Y}}) -> [?xuuu(Y, X, 197)];
asm({'binary',{r,X},{r,Y}}) -> [?xuuu(Y, X, 198)];
asm({'binary',{r,X},{literal,Y}}) when Y =< 65535, Y >= 0 -> [?dduu(Y, X, 199)];
asm({'binary',{r,X},{literal,Y}}) -> [?xxuu(X, 200), {literal,Y}];
asm({'bit_size',{r,X},{r,Y}}) -> [?xuuu(Y, X, 201)];
asm({'byte_size',{r,X},{r,Y}}) -> [?xuuu(Y, X, 202)];
asm({'add_mult',{r,X},{r,Y},Z}) when Z =< 255, Z >= 0 -> [?uuuu(Z, Y, X, 203)];
asm({'add_bit_size',{r,X},{r,Y}}) -> [?xuuu(Y, X, 204)];
asm({'bspl_i',{r,X},{r,Y},{r,Z},P,Q}) when P =< 255, P >= 0, Q =< 255, Q >= 0 -> [?uuuu(Z, Y, X, 205), ?xxuu(Q, P)];
asm({'bspl_i',{r,X},{literal,Y},{r,Z},P,Q}) when is_integer(Y), Y =< 32767, Y >= -32768, P =< 255, P >= 0, Q =< 255, Q >= 0 -> [?dduu(Y, X, 206), ?xuuu(Q, P, Z)];
asm({'bspl_i',{r,X},{literal,Y},{r,Z},P,Q}) when P =< 255, P >= 0, Q =< 255, Q >= 0 -> [?uuuu(P, Z, X, 207), ?xxxu(Q), {literal,Y}];
asm({'bspl_i',{r,X},{r,Y},{literal,Z},P}) when P =< 255, P >= 0 -> [?uuuu(P, Y, X, 208), {literal,Z}];
asm({'bspl_i',{r,X},{literal,Y},{literal,Z},P}) when is_integer(Y), Y =< 127, Y >= -128, P =< 255, P >= 0 -> [?uuuu(P, Y, X, 209), {literal,Z}];
asm({'bspl_i',{r,X},{literal,Y},{literal,Z},P}) when Z =< 255, Z >= 0, P =< 255, P >= 0 -> [?uuuu(P, Z, X, 210), {literal,Y}];
asm({'bspl_i',{r,X},{literal,Y},{literal,Z},P}) when is_integer(Y), Y =< 32767, Y >= -32768, Z =< 65535, Z >= 0, P =< 255, P >= 0 -> [?dduu(Y, X, 211), ?xudd(P, Z)];
asm({'bspl_i',{r,X},{literal,Y},{literal,Z},P}) when P =< 255, P >= 0 -> [?xuuu(P, X, 212), {literal,Y}, {literal,Z}];
asm({'bspl_f',{r,X},{r,Y},{r,Z},P,Q}) when P =< 255, P >= 0, Q =< 255, Q >= 0 -> [?uuuu(Z, Y, X, 213), ?xxuu(Q, P)];
asm({'bspl_f',{r,X},{literal,Y},{r,Z},P,Q}) when P =< 255, P >= 0, Q =< 255, Q >= 0 -> [?uuuu(P, Z, X, 214), ?xxxu(Q), {literal,Y}];
asm({'bspl_f',{r,X},{r,Y},{literal,Z},P}) when P =< 255, P >= 0 -> [?uuuu(P, Y, X, 215), {literal,Z}];
asm({'bspl_f',{r,X},{literal,Y},{literal,Z},P}) when Z =< 255, Z >= 0, P =< 255, P >= 0 -> [?uuuu(P, Z, X, 216), {literal,Y}];
asm({'bspl_f',{r,X},{literal,Y},{literal,Z},P}) when P =< 255, P >= 0 -> [?xuuu(P, X, 217), {literal,Y}, {literal,Z}];
asm({'bspl_b',{r,X},{r,Y},{r,Z},P,Q}) when P =< 255, P >= 0, Q =< 255, Q >= 0 -> [?uuuu(Z, Y, X, 218), ?xxuu(Q, P)];
asm({'bspl_b',{r,X},{literal,Y},{r,Z},P,Q}) when P =< 255, P >= 0, Q =< 255, Q >= 0 -> [?uuuu(P, Z, X, 219), ?xxxu(Q), {literal,Y}];
asm({'bspl_b',{r,X},{r,Y},{literal,Z},P}) when P =< 255, P >= 0 -> [?uuuu(P, Y, X, 220), {literal,Z}];
asm({'bspl_b',{r,X},{literal,Y},{literal,Z},P}) when Z =< 255, Z >= 0, P =< 255, P >= 0 -> [?uuuu(P, Z, X, 221), {literal,Y}];
asm({'bspl_b',{r,X},{literal,Y},{literal,Z},P}) when P =< 255, P >= 0 -> [?xuuu(P, X, 222), {literal,Y}, {literal,Z}];
asm({'bspl_b_all',{r,X},{r,Y},Z}) when Z =< 255, Z >= 0 -> [?uuuu(Z, Y, X, 223)];
asm({'bchip_i',{r,X},{r,Y},{r,Z},{r,P},Q,R,{l,T}}) when Q =< 255, Q >= 0, R =< 255, R >= 0 -> [?uuuu(Z, Y, X, 224), ?xuuu(R, Q, P), {l,T}];
asm({'bchip_i',{r,X},{r,Y},{r,Z},{literal,P},Q,{l,R}}) when P =< 65535, P >= 0, Q =< 255, Q >= 0 -> [?uuuu(Z, Y, X, 225), ?xudd(Q, P), {l,R}];
asm({'bchip_i',{r,X},{r,Y},{r,Z},{literal,P},Q,{l,R}}) when Q =< 255, Q >= 0 -> [?uuuu(Z, Y, X, 226), ?xxxu(Q), {literal,P}, {l,R}];
asm({'bchip_f',{r,X},{r,Y},{r,Z},{r,P},Q,R,{l,T}}) when Q =< 255, Q >= 0, R =< 255, R >= 0 -> [?uuuu(Z, Y, X, 227), ?xuuu(R, Q, P), {l,T}];
asm({'bchip_f',{r,X},{r,Y},{r,Z},{literal,P},Q,{l,R}}) when P =< 65535, P >= 0, Q =< 255, Q >= 0 -> [?uuuu(Z, Y, X, 228), ?xudd(Q, P), {l,R}];
asm({'bchip_f',{r,X},{r,Y},{r,Z},{literal,P},Q,{l,R}}) when Q =< 255, Q >= 0 -> [?uuuu(Z, Y, X, 229), ?xxxu(Q), {literal,P}, {l,R}];
asm({'bchip_b',{r,X},{r,Y},{r,Z},{r,P},Q,R,{l,T}}) when Q =< 255, Q >= 0, R =< 255, R >= 0 -> [?uuuu(Z, Y, X, 230), ?xuuu(R, Q, P), {l,T}];
asm({'bchip_b',{r,X},{r,Y},{r,Z},{literal,P},Q,{l,R}}) when P =< 65535, P >= 0, Q =< 255, Q >= 0 -> [?uuuu(Z, Y, X, 231), ?xudd(Q, P), {l,R}];
asm({'bchip_b',{r,X},{r,Y},{r,Z},{literal,P},Q,{l,R}}) when Q =< 255, Q >= 0 -> [?uuuu(Z, Y, X, 232), ?xxxu(Q), {literal,P}, {l,R}];
asm({'bchip_b_all',{r,X},{r,Y},Z}) when Z =< 255, Z >= 0 -> [?uuuu(Z, Y, X, 233)];
asm({'is_empty_binary',{r,X},{l,Y}}) -> [?xxuu(X, 234), {l,Y}];
asm({'catch',{l,X}}) -> [?xxxu(235), {l,X}];
asm('drop_catch') -> [?xxxu(236)];
asm(X) -> {badop,X}.

is_terminal_op(Op) when is_tuple(Op) ->
	is_terminal_op(element(1, Op));
is_terminal_op(enter) -> true;
is_terminal_op(enter_apply) -> true;
is_terminal_op(enter_bif) -> true;
is_terminal_op(enter_fun) -> true;
is_terminal_op(jump) -> true;
is_terminal_op(match_fail) -> true;
is_terminal_op(return) -> true;
is_terminal_op(_) -> false.

%%EOF
