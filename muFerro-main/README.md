![mupro_ferroelectric](https://user-images.githubusercontent.com/3356113/213937552-78a06111-84e7-4df1-982d-fa1faf512a56.png)

[![muFerro Build & Test](https://github.com/muprosoftware/PhaseFieldFerroelectric/actions/workflows/build_test.yml/badge.svg)](https://github.com/muprosoftware/PhaseFieldFerroelectric/actions/workflows/build_test.yml)

Powered by the [Mu-PRO PhaseFieldSDK](https://sdk.muprosoftware.com)

Check out the documentation site, [ferro.muprosoftware.com](https://ferro.muprosoftware.com)

## Dev dependencies

1. intel oneapi basekit + hpckit
2. cmake

## Usage

```sh
source /opt/intel/oneapi/setvars.sh
cmake --preset="linux-intel-Debug" -S "."
cmake --build --preset="linux-intel-Debug"
cmake --build --preset="linux-intel-Debug" --target build_doc
```


# Ferroelectric main program guidance

1. get input
2. normalize variables
3. modeling system setup, such as allocation, solver setup etc.
4. start the main loop to evolve the TDGL equation.
5. output
