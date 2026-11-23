# CS3300 Lab 1, variant a

Extension to **Assignment 1: MacroJava to MiniJava**.

You have this variant if the **last digit of your roll number modulo 3 is
0**. For example, CS23B087 ends in 7 and 7 % 3 = 1, so that student gets
variant b.

You have until the end of the session. You are extending **your own submitted
solution** to assignment 1, which you must download from the course Moodle. The
only network access is the course Moodle. Your own notes are allowed.

## Your task

Add **object-like expression macros** to MacroJava. Their syntax is:

```text
#defineConst MacroName (BodyExpression)
```

`MacroName` is an `Identifier`, and `BodyExpression` may be any `Expression`
accepted by the Assignment 1 grammar; it is not restricted to an integer. For
example:

```java
#defineConst TEN (10)
```

Unlike the existing macros, a constant macro is used without parentheses:

```java
System.out.println(TEN+TEN);
```

Whenever the plain identifier `MacroName` occurs as a primary expression,
replace it with the parenthesized stored body. The example above therefore
prints 20. Assignment 1 performs syntactic macro expansion, not type checking,
so the body need not be integer-valued. A plain identifier that is not the name
of a constant macro must remain an ordinary MiniJava identifier.

An object-like macro must not be followed by an argument list. Uses such as
`TEN()` or `TEN(1)` are invalid in both expression and statement positions and
must produce `//Failed to parse input code` as the first output line.

Constant bodies do not need to expand references to other macros. Programs
that do not use `#defineConst` must still be translated exactly as before.

## Where to change it

Add the new token to `A1.l`, then add the definition and expansion rules to
`A1.y`. A constant can be stored in the existing macro table with a flag that
distinguishes it from the existing function-like macros.

The `PrimaryExpression: Identifier` action is the point at which an identifier
can be looked up and either expanded or emitted unchanged.

## Testing

```sh
make
./A1.exe < some_test.java
```

Write examples that use a constant alone and as an arithmetic operand. Also
test an ordinary local variable: it must remain unchanged. All original
testcases must retain their existing outcomes.

## Submitting

Submit a gzip-compressed tar archive to the lab slot on Moodle **before you
leave the session**. Replace `cs99b999` below with your own roll number. The
archive must be named `cs99b999_P0.tar.gz` and contain one directory named
`cs99b999_P0`, with exactly these two files and nothing else:

```text
cs99b999_P0/
├── A1.l
└── A1.y
```

From the directory containing `cs99b999_P0`, create the archive with:

```sh
tar cvzf cs99b999_P0.tar.gz cs99b999_P0
```

Do **not** add the variant letter to the directory or archive name. Staff select
the matching variant when grading. Submit even if the change is incomplete.

## Marks

This lab is worth 6 of the 15 marks for assignment 1:

- 1 mark: `defineConst` is tokenized correctly.
- 2 marks: constant definitions are parsed and stored correctly.
- 2 marks: constant uses are expanded correctly.
- 1 mark: ordinary identifiers and existing programs still work.

Code that does not compile receives no marks. If your submitted solution cannot
be built, ask an invigilator for the reference implementation and extend that;
your total for assignment 1 is then capped at 50%.