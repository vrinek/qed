#!/bin/sh
if [ "$(uname)" = "Darwin" ]; then
  ruby main.rb
else
  LD_LIBRARY_PATH=$(pwd)/linux-bin ruby main.rb
fi
