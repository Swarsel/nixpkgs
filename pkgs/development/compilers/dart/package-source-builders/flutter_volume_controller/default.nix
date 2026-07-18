{
  stdenv,
}:

{ src, version, ... }:

stdenv.mkDerivation {
  inherit version src;
  inherit (src) passthru;
  pname = "flutter_volume_controller";

  postPatch = ''
    substituteInPlace linux/CMakeLists.txt \
      --replace-fail '# Include ALSA' 'find_package(PkgConfig REQUIRED)' \
      --replace-fail 'find_package(ALSA REQUIRED)' 'pkg_check_modules(ALSA REQUIRED alsa)'
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r ./* $out/

    runHook postInstall
  '';
}
