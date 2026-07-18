{
  lib,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  dpkg,
  gtk3,
  libgbm,
  libsecret,
  libxkbfile,
  makeBinaryWrapper,
  nix-update-script,
  nss,
  stdenvNoCC,
  wrapGAppsHook3,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rovium";
  version = "0.10.0";

  src = fetchurl {
    url = "https://github.com/rovium/rovium-beta/releases/download/v${finalAttrs.version}/rovium-${finalAttrs.version}-amd64.deb";
    hash = "sha256-kLSRYyUv1ideiqjqS4VTTTa64zL4jBMm1JMQvtBER10=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
    wrapGAppsHook3
    dpkg
  ];

  buildInputs = [
    alsa-lib
    gtk3
    libgbm
    nss
    libxkbfile
    libsecret
  ];

  installPhase = ''
    runHook preInstall

    substituteInPlace usr/share/applications/rovium.desktop \
      --replace-fail "/opt/Rovium/rovium" "$out/bin/rovium"

    install -D --mode=644 usr/share/applications/rovium.desktop \
      --target-directory=$out/share/applications

    install -D --mode=644 usr/share/icons/hicolor/512x512/apps/rovium.png \
      --target-directory=$out/share/icons/hicolor/512x512/apps

    cp --recursive opt $out

    makeWrapper $out/opt/Rovium/rovium $out/bin/rovium \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
      --set ELECTRON_ENABLE_LOGGING 0 \
      --set ELECTRON_NO_UPDATER 1 \
      --set DBUS_SESSION_BUS_ADDRESS "unix:path=/run/user/\$(id -u)/bus" \
      --add-flags "--no-sandbox" \
      --add-flags "--ozone-platform=x11" \
      --add-flags "--disable-update" \
      --add-flags "--disable-component-update" \
      --add-flags "--disable-breakpad" \
      --add-flags "--disable-background-networking" \
      --add-flags "--enable-features=UseOzonePlatform"

    runHook postInstall
  '';

  autoPatchelfIgnoreMissingDeps = [
    # Rovium binary is musl-static, libc is embedded
    "libc.musl-x86_64.so.1"
  ];

  dontWrapQtApps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Integrated Development Environment for ROS and Robotics";
    homepage = "https://rovium.dev";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ maximiliancf ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "rovium";
  };
})
