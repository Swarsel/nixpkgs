{ defaultMakeFlags, mkDerivation }:

mkDerivation {
  makeFlags = defaultMakeFlags ++ [ "BINDIR=$(out)/share" ];
  noCC = true;
  path = "share/dict";
}
