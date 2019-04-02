## Preparations
```shell
ln -s node_modules/circomlib/circuits lib
```

## Things that had to be circumvented
1. `snarkjs` can by default operate only on files in the root directory.
Anything located inside other directories requires explicit call to the compiler
using a bunch of magical flags. Script `generate_module.sh` takes a directory containing a .circom file and maybe inputs, then generates everything it can.
2. `circomlib` libraries are wrong. For example sha256/main.circom tries to import
some file called `sha256_2.jaz` and after that calls a function that doesn't exist (but it's just a lower/upper case issue).

## Things that just don't work
1. Compiling sha256 circuit -> JS out of memory!