#!/bin/bash

set -e

f=$@
if [ -d "$f" ]; then
    base=""
    dir="$f"
else
    base="/$(basename "$f")"
    dir=$(dirname "$f")
fi;
dir=$(cd "$dir" && pwd)
echo "$dir$base"
exit
