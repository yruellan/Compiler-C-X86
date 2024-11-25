#!/bin/bash

./Bash/build-dune.sh
./Bash/build-interpret.sh


cmake test -B test/build -D mode=interpret \
  && cmake --build test/build \
  && ctest --test-dir test/build