#!/bin/bash

< todos.psv cut -d '|' -f4 | sort | uniq -c | sort -k 1 -n -r | grep -v "<BR>" | head -10