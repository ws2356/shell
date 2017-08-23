#!/bin/sh

read -a word <<< 'hello bash suck it'
echo "word1: ${word[0]}, word2: ${word[1]}, word3: ${word[2]}, word4: ${word[3]}"
