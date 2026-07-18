{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation {
  pname = "emv";
  version = "1.95";

  src = fetchurl {
    url = "http://www.i0i0.de/toolchest/emv";
    sha256 = "7e0e12afa45ef5ed8025e5f2c6deea0ff5f512644a721f7b1b95b63406a8f7ce";
  };

  installPhase = ''
    mkdir -pv $out/bin
    cp $src $out/bin/emv
    chmod +x $out/bin/emv
  '';

  dontUnpack = true;

  meta = {
    description = "Editor Move: Rename files with your favourite text editor";
    homepage = "http://www.i0i0.de/toolchest/emv";
    license = lib.licenses.publicDomain;
    platforms = lib.platforms.unix;
    mainProgram = "emv";
  };
}
