#!/usr/bin/env python3
import fileinput
import re
import sys

# Usage: publicizer.py someFile.sol
#
# Replaces
#   uint256 internal /* publicForTesting */ someVar;
# with
#   uint256 public someVar;
#
# Also replaces "private" instead of "internal", as long as they're followed by
# /* publicForTesting */
#
# The modified file is printed to stdout.

p = re.compile('\s+(internal|public)\s*/\*\s*publicForTesting\s*\*/\s*')
replaceWith = ' public /* modifiedForTest */ '

def substitute(content):
  return p.sub(replaceWith, content)

if __name__ == "__main__":
  with open(sys.argv[1]) as file:
    print(substitute(file.read()))

