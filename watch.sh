#!/bin/sh
while true; do
  out=$(inotifywait -r -e modify -e create -e delete -e move package.json src/);
  if echo $out | grep 'DELETE\|MOVE'; then
    make clean;
  fi
  make install;
done
