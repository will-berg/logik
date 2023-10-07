% For SICStus, uncomment line below: (needed for member/2)
%:- use_module(library(lists)).
% Load model, initial state and formula from file.
verify(Input) :-
    see(Input), read(T), read(L), read(S), read(F), seen,
    check(T, L, S, [], F).
% check(T, L, S, U, F)
% T - The transitions in form of adjacency lists
% L - The labeling
% S - Current state
% U - Currently recorded states
% F - CTL Formula to check.
%
% Should evaluate to true iff the sequent below is valid.
%
% (T,L), S |- F
% U
% To execute: consult('your_file.pl'). verify('input.txt').
:- discontiguous(check/5).


% Literals
check(_, L, S, [], F) :-
    member([S, Adjacent], L),
    member(F, Adjacent).


% Not
check(T, L, S, [], neg(F)) :-
    \+ check(T, L, S, [], F).


% And
check(T, L, S, [], and(F,G)) :-
    check(T, L, S, [], F),
    check(T, L, S, [], G).


% Or
check(T, L, S, [], or(F, G)) :-
    check(T, L, S, [], F);
    check(T, L, S, [], G).


% EX
check(T, L, S, [], ex(F)) :-
    member([S, AdjacentNodes|_], T),
    member(NeighborNode, AdjacentNodes),
    check(T, L, NeighborNode, [], F).


% AX
check(T, L, S, [], ax(F)) :-
    member([S, AdjacentNodes|_], T),
    check_adjacent(T, L, AdjacentNodes, [], F).

check_adjacent(T, L, [], _, F).
check_adjacent(T, L, [Head|Tail], [], F) :-
    member([Head, List|_], L),
    check(T, L, Head, [], F),
    check_adjacent(T, L, Tail, [], F).


% AG
check(T, L, S, U, ag(F)) :-
    member(S, U).
check(T, L, S, U, ag(F)) :-
    \+ member(S, U),
    check(T, L, S, [], F),
    member([S, AdjacentNodes|_], T),
    append(U, [S], U2),
    check_adjacent_ag(T, L, AdjacentNodes, U2, F).

check_adjacent_ag(_, _, [], _, _).
check_adjacent_ag(T, L, [Head|Tail], U, F) :-
    check(T, L, Head, U, ag(F)),
    check_adjacent_ag(T, L, Tail, U, F).


% EG
check(T, L, S, U, eg(F)) :-
    member(S, U).
check(T, L, S, U, eg(F)) :-
    \+ member(S, U),
    check(T, L, S, [], F),
    member([S, AdjacentNodes|_], T),
    member(NeighborNode, AdjacentNodes),
    append(U, [S], U2),
    check(T, L, NeighborNode, U2, eg(F)).


% EF
check(T, L, S, U, ef(F)) :-
    \+ member(S, U),
    check(T, L, S, [], F).
check(T, L, S, U, ef(F)) :-
    \+ member(S, U),
    member([S, AdjacentNodes|_], T),
    member(NeighborNode, AdjacentNodes),
    append(U, [S], U2),
    check(T, L, NeighborNode, U2, ef(F)).


% AF
check(T, L, S, U, af(F)) :-
    \+ member(S, U),
    check(T, L, S, [], F).
check(T, L, S, U, af(F)) :-
    \+ member(S, U),
    member([S, AdjacentNodes|_], T),
    append(U, [S], U2),
    check_adjacent_af(T, L, AdjacentNodes, U2, F).

check_adjacent_af(_, _, [], _, _).
check_adjacent_af(T, L, [Head|Tail], U, F) :-
    check(T, L, Head, U, af(F)),
    check_adjacent_af(T, L, Tail, U, F).
