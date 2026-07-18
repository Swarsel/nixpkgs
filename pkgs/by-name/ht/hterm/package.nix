{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  cairo,
  expat,
  fontconfig,
  gtk2,
  libpng,
  libsm,
  pango,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hterm";
  version = "0.8.9";

  src =
    let
      versionWithoutDots = builtins.replaceStrings [ "." ] [ "" ] finalAttrs.version;
    in
    if stdenv.targetPlatform.is64bit then
      fetchurl {
        url = "https://www.der-hammer.info/terminal/hterm${versionWithoutDots}-linux-64.tgz";
        hash = "sha256-DY+X7FaU1UBbNf/Kgy4TzBZiocQ4/TpJW3KLW1iu0M0=";
      }
    else
      fetchurl {
        url = "https://www.der-hammer.info/terminal/hterm${versionWithoutDots}-linux-32.tgz";
        hash = "sha256-7wJFCpeXNMX94tk0QVc0T22cbv3ODIswFge5Cs0JhI8=";
      };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    cairo
    pango
    libpng
    expat
    fontconfig.lib
    gtk2
    libsm
  ];

  installPhase = ''
    runHook preInstall
    install -m755 -D hterm $out/bin/hterm
    install -m644 -D desktop/hterm.png -t $out/share/icons/hicolor/32x32/apps
    install -m644 -D desktop/hterm.desktop $out/share/applications/hterm.desktop
    runHook postInstall
  '';

  sourceRoot = ".";

  passthru = {
    updateScript = ./update.sh;
  };

  meta = {
    description = "Terminal program for serial communication";
    homepage = "https://www.der-hammer.info/pages/terminal.html";
    changelog = "https://www.der-hammer.info/terminal/CHANGELOG.txt";
    # See https://www.der-hammer.info/terminal/LICENSE.txt
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ zebreus ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];

    mainProgram = "hterm";
  };
})
