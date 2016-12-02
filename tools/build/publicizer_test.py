#!/usr/bin/env python3

import unittest
import publicizer as p


class PublicizerTest(unittest.TestCase):

    # Helpers
    def assertPublicized(self, expected, source):
      self.assertEqual(expected, p.substitute(source))

    def assertNotPublicized(self, source):
      self.assertEqual(source, p.substitute(source))

    # Tests
    def testDoesNotPublicizeIrrelevantStrings(self):
      self.assertNotPublicized("nothing")

    def testDoesNotPublicizeIrrelevantMultilineStrings(self):
      self.assertNotPublicized("line1\n line2\n")

    def testEmptyString(self):
      self.assertNotPublicized("")

    def testChangesInternalToPublic(self):
      self.assertPublicized(
        "uint256 public /* modifiedForTest */ x;",
        "uint256 internal /* publicForTesting */ x;")

    def testChangesPrivateToPublic(self):
      self.assertPublicized(
        "uint256 public /* modifiedForTest */ x;",
        "uint256 internal /* publicForTesting */ x;")

    def testDoesNotChangeOtherModifiers(self):
      self.assertNotPublicized(
        "uint256 external /* publicForTesting */ x;")

    def testEatsWhitespace(self):
      self.assertPublicized(
        "uint256 public /* modifiedForTest */ y;",
        "uint256   \n internal   /*   publicForTesting    */ y;")

if __name__ == "__main__":
    unittest.main()

