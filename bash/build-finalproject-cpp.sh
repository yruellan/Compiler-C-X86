#!/bin/bash

cmake src -B src/build  >> log.txt
make -C src/build/  >> log.txt