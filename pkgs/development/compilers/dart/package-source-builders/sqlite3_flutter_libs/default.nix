{
  stdenv,
}:

{ src, version, ... }:

stdenv.mkDerivation {
  inherit version src;
  inherit (src) passthru;
  pname = "sqlite3_flutter_libs";

  postPatch = ''
    cp ${./CMakeLists.txt} linux/CMakeLists.txt
  '';

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';
}
