#!/bin/sh
if [[ $(uname) == "Darwin" ]]; then
  ruby app/game.rb
else
  LD_LIBRARY_PATH=$(pwd)/linux-bin ruby app/game.rb
fi
