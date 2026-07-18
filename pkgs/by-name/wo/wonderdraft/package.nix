{
  lib,
  stdenv,
  alsa-lib,
  dpkg,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxinerama,
  libxrandr,
  pulseaudio,
  requireFile,
}:

stdenv.mkDerivation rec {
  pname = "wonderdraft";
  version = "1.1.8.2b";

  src = requireFile {
    url = "https://wonderdraft.net/";
    hash = "sha256-3eYnEH6P94z9axFsrkJA4QMcHyg/gNRczqL3h5Sc2Tg=";
    name = "Wonderdraft-${version}-Linux64.deb";
  };

  nativeBuildInputs = [
    dpkg
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -R usr/share opt $out/
    substituteInPlace \
      $out/share/applications/Wonderdraft.desktop \
      --replace /opt/ $out/opt/
    ln -s $out/opt/Wonderdraft/Wonderdraft.x86_64 $out/bin/Wonderdraft.x86_64
    runHook postInstall
  '';

  preFixup =
    let
      libPath = lib.makeLibraryPath [
        libxcursor
        libxinerama
        libxrandr
        libx11
        libxi
        libGL
        alsa-lib
        pulseaudio
      ];
    in
    ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath}" \
        $out/opt/Wonderdraft/Wonderdraft.x86_64
    '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Mapmaking tool for Tabletop Roleplaying Games, designed for city, region, or world scale";
    homepage = "https://wonderdraft.net/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ jsusk ];
    platforms = [ "x86_64-linux" ];
  };
}
