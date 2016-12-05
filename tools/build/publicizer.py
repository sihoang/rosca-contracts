#!/usr/bin/env python3

"""
Usage: publicizer.py someFile.sol

Replaces both
  uint256 internal /* publicForTesting */ someVar;
  and
  uint256 private /* publicForTesting */ someVar;
with
  uint256 public /* modifiedForTest */ someVar;

NOTE: The original file f is backed up to f.backup.<current time> and is overwritten
with the modified file.

"""

import math
import re
from shutil import copyfile
import sys
import time



def substitute(content):
  """Does the actual substitution"""

  p = re.compile(r'\s+(internal|public)\s*/\*\s*publicForTesting\s*\*/\s*')
  replaceWith = ' public /* modifiedForTest */ '

  replacedContent =  p.sub(replaceWith, content)
  return replacedContent

if __name__ == "__main__":
  currentTime = math.floor(time.time())
  copyfile(sys.argv[1], sys.argv[1] + ".backup." + str(currentTime))
  with open(sys.argv[1], "r+") as file:
    newcontent = substitute(file.read())
    file.seek(0)
    file.write(newcontent)

