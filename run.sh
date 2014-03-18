#!/bin/sh 
white=$1
black=$2

echo "ruby reversi.rb --interval=0.1 --timeout=5 --match=3 --white=$white --black=$black"
echo -n "Ready "
for n in `seq 1 5`; do
  echo -n "."
  sleep 1
done
echo "GO!!" && sleep 1

ruby reversi.rb --interval=0.5 --timeout=5 --match=3 --white=$white --black=$black
