#!/bin/bash

< todos.psv grep -vE "Oval|Circle|Sphere" | cut -d '|' -f4 | sort | uniq -c | sort -k 1 -n -r | grep -v "<BR>" | head -5