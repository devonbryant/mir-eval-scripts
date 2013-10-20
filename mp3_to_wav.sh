#!/bin/bash
# Helper script to convert all mp3 files in the current 
# directory (and sub-directories) into wav files

find . -type f -name "*.mp3" -exec sh -c '
  for f in "$@"
  do
	mpg123 -r 44100 --stereo -b 3072 -w "${f%.mp3}.wav" "$f"
  done
' _ {} +
