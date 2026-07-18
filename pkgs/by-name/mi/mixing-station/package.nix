{
  lib,
  stdenv,
  fetchzip,
  jre,
  libGL,
  libglvnd,
  libpulseaudio,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxxf86vm,
  makeWrapper,
  udev,
  unzip,
  which,
  yad,
  zenity,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mixing-station";
  version = "3.0.1";

  src = fetchzip {
    url = "https://mixingstation.app/backend/api/web/download/archive/mixing-station-pc/update/${finalAttrs.version}";
    hash = "sha256-WpjBqiYVuqIuDiigX2lg81I02qad/vZudqdWUe2h5Sw=";
    extension = "zip";
    name = "mixing-station-${finalAttrs.version}.zip";
    stripRoot = false;
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase =
    let
      runtimeLibs = lib.makeLibraryPath [
        libGL
        libglvnd
        libx11
        libxext
        libxcursor
        libxrandr
        libxi
        libxxf86vm
        libxinerama
        libpulseaudio
        udev
      ];
      dialogTools = [
        zenity
        yad
        which
      ];
    in
    ''
      runHook preInstall
      install -Dm644 mixing-station-desktop.jar \
        "$out/share/mixing-station/mixing-station-desktop.jar"
      makeWrapper "${jre}/bin/java" "$out/bin/mixing-station" \
            --add-flags "-Dawt.useSystemAAFontSettings=gasp" \
            --add-flags "-jar $out/share/mixing-station/mixing-station-desktop.jar" \
            --prefix LD_LIBRARY_PATH : "${runtimeLibs}" \
            --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib" \
            --suffix PATH : "${lib.makeBinPath dialogTools}"
      runHook postInstall
    '';

  dontBuild = true;

  meta = {
    description = "Remote control app for digital audio mixers (XAir, X32, dLive, etc.)";
    homepage = "https://mixingstation.app";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = with lib.maintainers; [ korny666 ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "mixing-station";
  };
})
