{
  compatIfNeeded,
  libjail,
  mkDerivation,
}:
mkDerivation {
  buildInputs = compatIfNeeded ++ [ libjail ];
  MK_TESTS = "no";
  path = "sbin/route";
}
