# oppress

chainable higher-order functions for `std/options` and result types.

```nim
import oppress

type str = string     

proc test(x: string): Option[string] = some ("hey, " & x)

##### options #####
none(string)
.and_then(test)
.or_else(() => some "stranger")
.filter((x: str) => ( # multi-line code without block (notice the semicolon)
  echo x;
  x != "stranger"
))
.or_else(() => some "badass")
.take_if((x: str) => (block: # multi-line code with block (no semicolons)
  echo x
  x == "badass"
))
.echo
```