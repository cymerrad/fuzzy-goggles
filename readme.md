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
3. Compiling sha256 circuit runs out of NodeJS allowed memory. Workaround:
`NODE_OPTIONS="--max-old-space-size=4096" yarn circom lib/sha256/main.circom -o sha256/main.json` .
This creates a 253MB json file. Wow.


## Things that just don't work
1. Nothing but a totally impractical 253MB file for now.