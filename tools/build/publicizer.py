#!/usr/bin/env python3

"""
Usage: publicizer.py someFile.sol

Replaces
  uint256 internal /* publicForTesting */ someVar;
with
  uint256 public /* modifiedForTest */ someVar;

Also replaces "private" instead of "internal", as long as they're followed by
/* publicForTesting */

The modified file is printed to stdout.

"""

import re
import sys


def substitute(content):
  """Does the actual substitution"""

  p = re.compile(r'\s+(internal|public)\s*/\*\s*publicForTesting\s*\*/\s*')
  replaceWith = ' public /* modifiedForTest */ '

  return p.sub(replaceWith, content)

if __name__ == "__main__":
  with open(sys.argv[1]) as file:
    print(substitute(file.read()))

