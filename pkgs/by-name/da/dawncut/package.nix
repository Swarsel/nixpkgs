{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "dawncut";
  version = "1.54a";

  src = fetchurl {
    url = "https://geant4.kek.jp/~tanaka/src/dawncut_${
      builtins.replaceStrings [ "." ] [ "_" ] version
    }.taz";

    hash = "sha256-Ux4fDi7TXePisYAxCMDvtzLYOgxnbxQIO9QacTRrT6k=";
    name = "${pname}-${version}.tar.gz";
  };

  postPatch = ''
    substituteInPlace Makefile.architecture \
      --replace 'CXX      := g++' ""
  '';

  env.NIX_CFLAGS_COMPILE = "-std=c++98";

  installPhase = ''
    runHook preInstall

    install -Dm 500 dawncut "$out/bin/dawncut"

    runHook postInstall
  '';

  dontConfigure = true;

  meta = {
    description = "Tool to generate a 3D scene data clipped with an arbitrary plane";
    homepage = "https://geant4.kek.jp/~tanaka/DAWN/About_DAWNCUT.html";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ veprbl ];
    platforms = lib.platforms.unix;
  };
}
