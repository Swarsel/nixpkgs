{
  lib,
  stdenv,
  fetchurl,
  avahi-compat,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "altserver-linux";
  version = "0.0.5";

  src = fetchurl {
    url = "https://github.com/NyaMisty/AltServer-Linux/releases/download/v${finalAttrs.version}/AltServer-x86_64";
    hash = "sha256-C+fDrcaewRd6FQMrO443xdDk/vtHycQ5zWLCOLPqF/s=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp $src $out/bin/alt-server
    chmod u+x $out/bin/alt-server

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "AltServer for AltStore, but on-device. Requires root privileges as well as running a custom anisette server currently";
    homepage = "https://github.com/NyaMisty/AltServer-Linux";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ max-amb ];
    platforms = lib.platforms.linux;
    mainProgram = "alt-server";
  };
})
