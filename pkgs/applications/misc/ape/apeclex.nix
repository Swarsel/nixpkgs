{
  lib,
  attemptoClex,
  callPackage,
}:

callPackage ./. {
  pname = "ape-clex";
  description = "Parser for Attempto Controlled English (ACE) with a large lexicon (~100,000 entries)";
  lexiconPath = "${attemptoClex}/clex_lexicon.pl";

  license = with lib.licenses; [
    lgpl3
    gpl3
  ];
}
