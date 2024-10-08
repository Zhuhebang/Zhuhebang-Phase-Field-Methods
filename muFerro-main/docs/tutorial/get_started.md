# Quick Start

For a quick start, you should use the examples in the apps folder of this repository.

## Build

1. Create your own CMakeUserPresets.json file from the provided template. `cp CMakeUserPresets.template CMakeUserPresets.json`
2. Update the presets in the CMakeUserPresets.json file, particularly set the mupro_ROOT cacheVariables to the location where your mupro phasefieldsdk is installed.
3. Configure the project `cmake --preset="my-intel-Debug" -S "."`
4. Build the project `cmake --build --preset="my-intel-Debug"`