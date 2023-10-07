# Labb 1 - Prolog

### Uppgift 1 - Unifiering
*Betrakta denna fråga till ett Prologsystem:*
```prolog
| ?- T=f(a,Y,Z), T=f(X,X,b).
```
*Vilka bindningar presenteras som resultat? Ge en kortfattad förklaring till ditt svar!*
___
Dessa bindningar presenteras som resultat efter att frågan har körts i gprolog:
```prolog
T = f(a,a,b)
X = a
Y = a
Z = b
```
När ovan fråga ställs till Prologsystemet försöker den att unifiera termerna och frågan blir alltså vilka värden termerna måste anta för att
`T=f(a,Y,Z), T=f(X,X,b)` ska vara ekvivalenta. Detta sker när `X = a`, `Y = a` och `Z = b` och då blir `T = f(a,a,b)`. För att unifieringen ska fungera måste alltså variablerna X,Y,Z instansieras till dem värdena.
___

### Uppgift 2 - Negation
*I Prolog hanteras negation oftast med "negation-as failure". Förklara denna princip och ge ett enkelt exempel!*
___
"Negation-as failure" är ett koncept inom logikprogrammering och Prolog som ger oss möjligheten att bland annat uttrycka regelundantag. "Cut fail" kombinationen `!,fail` låter oss definiera denna "negation as failure" princip och fungerar på följande sätt: När vi når cut `!` blockeras åtkomsten till andra regeln, backtracking blockeras och alla förändringar vi har gjort hittills låses fast. Sedan kommer vi till `fail` vilket försöker forcera backtracking - men cut blockerar detta och frågan misslyckas. Denna princip behöver inte definieras överhuvudtaget av programmeraren, utan har sin egna operator i Prolog `\+`. Ett predikat föregånget av denna operator kommer att negeras (NOT). Dock fungerar det inte exakt som den logiska NOT operatorn. Nedan är ett exempel på Prolog kod som använder sig av denna negationsprincip:
```prolog
eats(gordon, X) :- chicken(X), \+ raw(X).
```
Detta innebär att Gordon äter X *om* X är en kyckling och X *inte* är rå.
___

### Uppgift 3 - Representation
*En lista är en representation av sekvenser där den tomma sekvensen representeras av symbolen [] och en sekvens bestående av tre heltal 1, 2 och 3 representeras av [1,2,3]. Den exakta definitionen av en lista är:*
```prolog
list([]).
list([H|T]) :- list(T).
```
*Vi vill definiera ett predikat som givet en lista som representerar en sekvens skapar en annan lista som innehåller alla element som förekommer i inlistan i samma ordning, men om ett element har förekommit tidigare i listan skall det inte vara med i den resulterande listan. Till exempel,*
```prolog
?- remove_duplicates([1,2,3,2,4,1,3,4], E).
```
*skall generera `E=[1,2,3,4]`. Definiera alltså predikatet `remove_duplicates/2`!*
___
```prolog
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
```
