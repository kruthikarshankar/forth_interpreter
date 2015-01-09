# forth_interpreter
FORTH interpreter in Prolog and Haskell

FORTH is a cute language meant for control and embedded systems applications. It comes with a lot of functionality, but for this assignment, you will be implementing only a small subset of the entire language. You can read more about FORTH on web sites like forth.org and the pForth website.

The central entity in FORTH is the stack. You push things onto the stack and do operations from there. A FORTH program is a bunch of "words" with spaces between them. For instance, the following is a simple FORTH program:


23 7 91

All it does is to push the three above numbers onto the stack. 91 is on top and 23 is at the bottom (last in, first out).

Here's another FORTH program:

23 7 91 DROP

The only difference between this and the previous is the word "DROP" at the end of it. The word (or command) DROP pops (removes) the top element off the stack and discards it. After this, only two numbers are remaining (23 and 7) on the stack. 7 is on the top.
We can also do arithmetic operations on the stack. "+" takes the top two elements off the stack, adds them, and pushes the result back. Similarly for "-", "*", and "/". So,

4 5 +

leaves the stack containing the single value 9.

3 4 - 5 +

leaves the stack containing the single value 4. Note that the operations are applied to the values on the stack purely left-to-right, giving FORTH a postfix notational style without any operator precedence.

FORTH provides other operations for manipulating the stack. DUP duplicates the topmost element on the stack.

77 DUP
This short line of FORTH leaves the stack containing 77 and 77. Similarly, SWAP swaps the topmost two elements on the stack.

8 7 SWAP
After evaluating this short FORTH program, the stack contains 7 on the bottom and 8 on the top. OVER causes a copy of the second element on the stack to leapfrog over the first.

8 9 OVER
The FORTH program above leaves the stack containing [8, 9, 8]. Finally, ROT takes the third element from the stack and moves it to the top.

7 8 9 ROT
This leaves the stack containing 8 on the bottom, 9 in the middle, and 7 on top. Some more examples:

FORTH Program		FORTH-style Stack Result (top on right)			Haskell-style Stack Result (list, top on left)
11 22 33 SWAP DUP	11 33 22 22										[22, 22, 33, 11]
11 22 33 ROT DROP	22 33											[33, 22]
11 22 33 + -		-44												[-44]

An Interpreter in Haskell
A Haskell function called interpretFORTHProgram with the following signature:

interpretFORTHProgram :: String -> Maybe Stack

This function takes a single input parameter: the FORTH "program" to interpret/execute. Our FORTH programs are only going to deal with integer values on the stack, and the return value from your interpreter will be the final state of the FORTH stack after "executing" the series of words given in the parameter. A syntactically correct FORTH program is simply a string that contains any combination of integers and FORTH words, separated by white space.

Since we are using Haskell and are representing the stack using a list, We will represent our stacks with the TOP on the LEFT (note that this is the opposite of the order that FORTH would normally print things). That means that the Haskell list versions of stacks will be the REVERSE of the examples in FORTH given above.

Besides integer literals, your interpreter must support all the FORTH words in the following table:


\+ -->	( n1 n2 -- sum )-->	Adds (n1 + n2).

\-	-->    ( n1 n2 -- diff )	--> 	Subtracts (n1 - n2).

\*	-->    ( n1 n2 -- prod )	-->		Multiplies (n1 * n2).

/	-->  ( n1 n2 -- quot )	 -->	Divides (n1 / n2), using integer division (truncates).

/MOD   --> 	( n1 n2 -- rem quot )	-->		Divides. Returns the remainder and quotient.

MOD	 --> 	( n1 n2 -- rem )	--> 	Returns the remainder from division.

=	-->  ( n1 n2 -- equal )	-->	Compares for equality (n1 == n2). Indicates false with the value zero, and true with the value -1.

<	-->	 ( n1 n2 -- less )	--> 	Compares using "less than" (n1 < n2). Indicates false with the value zero, and true with the value -1.

AND	--> 	( n1 n2 -- and )	--> 	Combines two conditions using logical "and", where zero is false and non-zero is true.

OR		-->		( n1 n2 -- or ) 	--> 	Combines two conditions using logical "OR", where zero is false and non-zero is true.

SWAP  -->	( n1 n2 -- n2 n1 )	-->	Reverses the top two stack items.

DUP	-->	( n -- n n )	-->	Duplicates the top stack item.

OVER 	-->		( n1 n2 -- n1 n2 n1 )	-->	Makes a copy of the second item and pushes it on top.

ROT		-->		( n1 n2 n3 -- n2 n3 n1 )	-->	Rotates the third item to the top.

DROP	( n -- )	-->	Discards the top stack item.

2SWAP -->	( n1 n2 n3 n4 -- n3 n4 n1 n2 )	-->		Reverses the top two pairs of numbers.

2DUP -->	( n1 n2 -- n1 n2 n1 n2 )	-->	Duplicates the top pair of numbers.

2OVER -->	( n1 n2 n3 n4 -- n1 n2 n3 n4 n1 n2 ) -->	Makes a copy of the second pair of numbers and pushes it on top.

2DROP -->	( n1 n2 -- )	-->	Discards the top pair of numbers.

In FORTH, It is common for one to describe the "signature" of a word (an operation) in terms of how many values it pops off the stack, and what new it pushes onto the stack in the basic form:

( before -- after )
The dash separates the things that should be on the stack (before you execute the word) from the things that will be left there afterwards. For example, here's the stack notation for the word DROP:

DROP ( n -- )
(The letter "n" stands for "number.") This shows that DROP expects one number on the stack (before) and leaves no number on the stack (after).

Here's the stack notation for the word +:

+ ( n1 n2 -- sum )

When there is more than one n, we number them n1, n2, n3, etc., consecutively. The numbers 1 and 2 do not refer to a position on the stack. Stack position is indicated by the order in which the items are written; the rightmost item on either side of the double-dash is the topmost item on the stack. For example, in the stack notation of +, the n2 is on top before the operation.

