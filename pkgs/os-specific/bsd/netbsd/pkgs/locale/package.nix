{ mkDerivation }:

mkDerivation {
  patches = [ ./locale.patch ];
  env.NIX_CFLAGS_COMPILE = "-DYESSTR=__YESSTR -DNOSTR=__NOSTR";
  path = "usr.bin/locale";
}
