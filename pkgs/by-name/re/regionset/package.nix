{
  lib,
  stdenv,
  fetchurl,
}:

let
  version = "0.2";
in
stdenv.mkDerivation {
  inherit version;
  pname = "regionset";

  src = fetchurl {
    url = "http://linvdr.org/download/regionset/regionset-${version}.tar.gz";
    sha256 = "1fgps85dmjvj41a5bkira43vs2aiivzhqwzdvvpw5dpvdrjqcp0d";
  };

  installPhase = ''
    install -Dm755 {.,$out/bin}/regionset
    install -Dm644 {.,$out/share/man/man8}/regionset.8
    install -Dm644 {.,$out/share/doc/regionset}/README
  '';

  prePatch = ''
    substituteInPlace regionset.8 \
        --replace-fail /usr/share/doc/ "$out"/share/doc/
  '';

  meta = {
    inherit version;
    description = "Tool for changing the region code setting of DVD players";
    homepage = "http://linvdr.org/projects/regionset/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "regionset";
  };
}
