# CS3300 Lab 2, variant c

Extension to **Assignment 2: MiniJava to a verdict**.

You have this variant if the **numeric suffix of your roll number modulo 3 is
2**. Use all digits after the final letter, interpreted as a decimal number:
CS23B087 has suffix `087`, so 87 % 3 = 0 and that student gets variant a.
The mapping is 0 -> a, 1 -> b, 2 -> c; for example, `009` gets a and `010` gets b.

You have until the end of the session. You are extending **your own submitted
solution** to assignment 2, which you must download from the course Moodle. The
only network access is the course Moodle. Your own notes are allowed.

## Your task

Reject any class that declares a field with the same name as a field it
inherits, at any depth in the inheritance chain.

Report a violation the same way the existing checks do: print `Type error` and
stop. Programs that do not break the rule must still produce
`Program type checked successfully` (or whatever verdict they produced before).

**Hint:** you will be walking up the chain of parent classes. Make sure a
program with cyclic inheritance cannot send you round that loop forever.

## Where to change it

`visitor/GJDepthFirst.java`.

## Testing

```sh
javac P1.java
java P1 < some_test.java
```

Test a field shadowing an immediate parent field and a more distant ancestor
field. Also test distinct field names, name reuse in unrelated classes, and
cyclic inheritance: it must be rejected without looping.
The testcases you were given for the take-home must all still produce the same
verdict as before, apart from any that genuinely break the new rule.

## Submitting

Submit a gzip-compressed tar archive to the lab slot on Moodle **before you
leave the session**. Replace `cs99b999` below with your own roll number. Keep
the existing directory structure and file names. The archive must be named
`cs99b999_P1.tar.gz` and contain the top-level directory
`cs99b999_P1`.

Remove compiled `.class` files, then create the archive from the directory
containing `cs99b999_P1`:

```sh
find cs99b999_P1 -name '*.class' -delete
tar cvzf cs99b999_P1.tar.gz cs99b999_P1
```

Do **not** add the variant letter to the directory or archive name. Staff select
the matching variant when grading. What you submit is what is marked, so submit
even if the change is incomplete.

## Marks

This lab is worth 6 of the 15 marks for assignment 2:

- 1 mark: declared fields and the parent-class chain are identified correctly.
- 2 marks: fields that shadow a field declared in the immediate parent are rejected.
- 2 marks: fields that shadow a field in a more distant ancestor are rejected.
- 1 mark: programs unaffected by the new rule retain their existing verdicts, and cyclic inheritance is rejected without looping.

Code that does not compile receives no marks. If your submitted solution cannot
be built, ask an invigilator for the reference implementation and extend that;
your total for assignment 2 is then capped at 50%.