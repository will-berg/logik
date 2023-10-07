/* Call helper with empty list accumulator, all unique
elements will be copied to the accumulator */
remove_duplicates(Inlist, Outlist) :-
    rem_dup_help(Inlist, [], Outlist).

/* We are done if we have gone through the entire inlist,
bind accumulated value to the Outlist */
rem_dup_help([], Acc, Acc).
/* If the head is a member of the accumulator, recurse over the tail */
rem_dup_help([H|T], Acc, Outlist) :-
    memberchk(H, Acc),
    rem_dup_help(T, Acc, Outlist).
/* If the head is not a member of the accumulator, append the head to the
accumulator and recurse over the tail */
rem_dup_help([H|T], Acc, Outlist) :-
    append(Acc, [H], Acc2),
    rem_dup_help(T, Acc2, Outlist), !.
