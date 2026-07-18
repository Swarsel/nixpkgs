{
  stdenv,
  xdg-user-dirs,
}:

{ src, version, ... }:

stdenv.mkDerivation rec {
  inherit version src;
  inherit (src) passthru;
  pname = "xdg_directories";

  postPatch = ''
    substituteInPlace ./lib/xdg_directories.dart \
      --replace-fail "'xdg-user-dir'," "'${xdg-user-dirs}/bin/xdg-user-dir',"
  '';

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';
}
