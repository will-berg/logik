/* Verification predicate verifies if the proof is correct for the given input file
containing a sequent (premisses and goal) and a natural deduction proof

The goal is stored in the Goal variable, the premisses are stored in the Prems list
and the Proof is stored in the Proof list */
verify(InputFileName) :- see(InputFileName),
                         read(Prems), read(Goal), read(Proof),
                         seen,
                         goal_equal(Goal, Proof),
                         valid_proof(Prems, Proof, []).


% Main algorithm, calls line_clearer that checks the natural deduction rules
valid_proof(_, [], _).
valid_proof(Prems, [H|T], ClearedLines) :-
    line_clearer(Prems, H, ClearedLines),
    append(ClearedLines, [H], ClearedLines2),
    valid_proof(Prems, T, ClearedLines2).


/* The first thing to do is check that what is stored in the Goal variable is
on the last line in the proof */
goal_equal(Goal, Proof) :-
    last(Proof, X),
    member(Goal, X).


/* Helper predicates for double and single member checks. double_member is used for natural
deduction rules with 2 arguments and single_member is used for 1 argument rules */
double_member(Line1, Line2, Value1, Value2, ClearedLines) :-
    member([Line1, Value1|_], ClearedLines),
    member([Line2, Value2|_], ClearedLines).

single_member(Line, Value, ClearedLines) :-
    member([Line, Value|_], ClearedLines).


% Helper predicate for assumption rules
assumption_member(Line1, Line2, Value1, Value2, ClearedLines) :-
    member(Box, ClearedLines),
    member([Line1, Value1, assumption|_], Box),
    last(Box, [Line2, Value2|_]).


% Natural deduction rules, H will represent the line currently being cleared

% If the line is a premise and the premise is among the specified premises, it is OK
line_clearer(Prems, H, _) :-
    H = [_, Value, premise|_],
    member(Value, Prems).


% Checks for and-introduction
line_clearer(_, H, ClearedLines) :-
    H = [_, and(X, Y), andint(Line1, Line2)|_],
    double_member(Line1, Line2, X, Y, ClearedLines).


% Checks for and-elimination 1
line_clearer(_, H, ClearedLines) :-
    H = [_, X, andel1(Line)|_],
    single_member(Line, and(X, _), ClearedLines).


% Checks for and-elimination 2
line_clearer(_, H, ClearedLines) :-
    H = [_, Y, andel2(Line)|_],
    single_member(Line, and(_, Y), ClearedLines).


% Checks for or-introduction 1
line_clearer(_, H, ClearedLines) :-
    H = [_, or(X, _), orint(Line)|_],
    single_member(Line, X, ClearedLines).


% Checks for or-introduction 2
line_clearer(_, H, ClearedLines) :-
    H = [_, or(_, Y), orint(Line)|_],
    single_member(Line, Y, ClearedLines).


% Checks if copy is used correctly
line_clearer(_, H, ClearedLines) :-
    H = [_, X, copy(Line)|_],
    single_member(Line, X, ClearedLines).


% Checks for implication-elimination
line_clearer(_, H, ClearedLines) :-
    H = [_, X, impel(Line1, Line2)|_],
    double_member(Line1, Line2, Y, imp(Y, X), ClearedLines).


% Checks for negation-elimination
line_clearer(_, H, ClearedLines) :-
    H = [_, _, negel(Line1, Line2)|_],
    double_member(Line1, Line2, X, neg(X), ClearedLines).


% Checks for double-negation elimination
line_clearer(_, H, ClearedLines) :-
    H = [_, X, negnegel(Line)|_],
    single_member(Line, neg(neg(X)), ClearedLines).


% Checks for double-negation introduction
line_clearer(_, H, ClearedLines) :-
    H = [_, neg(neg(X)), negnegint(Line)|_],
    single_member(Line, X, ClearedLines).


% Checks for law of excluded middle (LEM)
line_clearer(_, H, _) :-
    H = [_, or(X, neg(X)), lem|_].


% Checks for mt (modus tollens)
line_clearer(_, H, ClearedLines) :-
    H = [_, neg(X), mt(Line1, Line2)|_],
    double_member(Line1, Line2, imp(X, Y), neg(Y), ClearedLines).


% Checks for contradiction-elimination
line_clearer(_, H, ClearedLines) :-
    H = [_, _, contel(Line)|_],
    single_member(Line, cont, ClearedLines).


/* Checks for assumption on line H, T will be set to the tail of the assumption line,
meaning that T will contain the remaining lines (lists) of the box */
line_clearer(Prems, H, ClearedLines) :-
    H = [[_, _, assumption|_]|T],
    append(ClearedLines, H, ClearedLinesBox),
    valid_proof(Prems, T, ClearedLinesBox).


% Checks for implication-introduction
line_clearer(_, H, ClearedLines) :-
    H = [_, imp(X, Y), impint(Line1, Line2)|_],
    assumption_member(Line1, Line2, X, Y, ClearedLines).


% Checks for proof by contradiction (PBC)
line_clearer(_, H, ClearedLines) :-
    H = [_, X, pbc(Line1, Line2)|_],
    assumption_member(Line1, Line2, neg(X), cont, ClearedLines).


% Checks for negation-introduction
line_clearer(_, H, ClearedLines) :-
    H = [_, neg(X), negint(Line1, Line2)|_],
    assumption_member(Line1, Line2, X, cont, ClearedLines).


% Checks for or-elimination
line_clearer(_, H, ClearedLines) :-
    H = [_, X, orel(Line, Box1Start, Box1End, Box2Start, Box2End)|_],
    member([Line, or(Y, Z)|_], ClearedLines),
    assumption_member(Box1Start, Box1End, Y, X, ClearedLines),
    assumption_member(Box2Start, Box2End, Z, X, ClearedLines).
