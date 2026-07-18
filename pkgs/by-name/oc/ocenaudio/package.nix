{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  bzip2,
  dpkg,
  libjack2,
  libpulseaudio,
  qt6,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ocenaudio";
  version = "3.20.0";

  src = fetchurl {
    url = "https://www.ocenaudio.com/downloads/index.php/ocenaudio_debian12.deb?version=v${finalAttrs.version}";
    hash = "sha256-iykGoFPyxJGyF4S1YjNS1XKkGrxxgK+xxA4gyVsgw8E=";
    name = "ocenaudio.deb";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    qt6.wrapQtAppsHook
    dpkg
  ];

  buildInputs = [
    xz
    qt6.qtbase
    bzip2
    libjack2
    alsa-lib
    libpulseaudio
  ];

  installPhase = ''
    runHook preInstall

    cp -r opt/ocenaudio $out
    cp -r usr/share $out/share
    substituteInPlace $out/share/applications/ocenaudio.desktop \
      --replace-fail "/opt/ocenaudio/bin/ocenaudio" "ocenaudio"
    mkdir -p $out/share/licenses/ocenaudio
    mv $out/bin/ocenaudio_license.txt $out/share/licenses/ocenaudio/LICENSE
    # Create symlink bzip2 library
    ln -s ${bzip2.out}/lib/libbz2.so.1 $out/lib/libbz2.so.1.0

    runHook postInstall
  '';

  autoPatchelfIgnoreMissingDeps = [
    "libqtocenai.so.3.15"
    "libqtocencore.so.3.15"
  ];

  dontBuild = true;
  dontStrip = true;

  meta = {
    description = "Cross-platform, easy to use, fast and functional audio editor";
    homepage = "https://www.ocenaudio.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ onny ];
    platforms = [ "x86_64-linux" ];
  };
})
