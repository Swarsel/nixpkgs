{
  compatIfNeeded,
  lib80211,
  libifconfig,
  libjail,
  libnv,
  mkDerivation,
}:
mkDerivation {
  buildInputs = compatIfNeeded ++ [
    libifconfig
    lib80211
    libjail
    libnv
  ];

  # ifconfig believes libifconfig is internal and thus PIE.
  # We build libifconfig as an external library
  MK_PIE = "no";
  MK_TESTS = "no";
  path = "sbin/ifconfig";
}
