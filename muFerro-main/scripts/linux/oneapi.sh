#!/bin/sh

if command -v ifx >/dev/null 2>&1; then
  echo "oneapi already activated"
else
  source /opt/intel/oneapi/setvars.sh
fi
