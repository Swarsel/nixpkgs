{
  lib,
  stdenv,
  fetchurl,
  jre,
  nix-update-script,
  swt,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "biglybt";
  version = "3.9.0.0";

  src = fetchurl {
    url = "https://github.com/BiglySoftware/BiglyBT/releases/download/v${finalAttrs.version}/GitHub_BiglyBT_unix.tar.gz";
    hash = "sha256-NBXEY5f2kVPoZit7Gy4rM61bwQSdXovg0gURukhxJJ4=";
  };

  nativeBuildInputs = [
    swt
    wrapGAppsHook3
  ];

  buildInputs = [
    swt
  ];

  installPhase = ''
    runHook preInstall

    install -d $out/{share/{biglybt,applications,icons/hicolor/scalable/apps},bin}

    cp -r ./* $out/share/biglybt/

    ln -s ${swt}/lib/* $out/share/biglybt/
    rm -rf $out/share/biglybt/swt/*.jar $out/share/biglybt/swt/J17/*.jar
    ln -s ${swt}/jars/swt.jar $out/share/biglybt/swt/swt-$(uname -m).jar
    ln -s ${swt}/jars/swt.jar $out/share/biglybt/swt/J17/swt-$(uname -m).jar

    ln -s $out/share/biglybt/biglybt.desktop $out/share/applications/

    ln -s $out/share/biglybt/biglybt.svg $out/share/icons/hicolor/scalable/apps/

    wrapProgram $out/share/biglybt/biglybt \
      --prefix PATH : ${lib.makeBinPath [ jre ]}

    ln -s $out/share/biglybt/biglybt $out/bin/
    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    sed -e 's/AUTOUPDATE_SCRIPT=1/AUTOUPDATE_SCRIPT=0/g' \
      -i biglybt || die

    runHook postConfigure
  '';

  runtimeDeps = [
    swt
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^(v[0-9.]+)$"
    ];
  };

  meta = {
    description = "BitTorrent client based on the Azureus that supports I2P darknet for privacy";
    homepage = "https://www.biglybt.com/";
    changelog = "https://github.com/BiglySoftware/BiglyBT/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ raspher ];
    platforms = lib.platforms.unix;
    mainProgram = "biglybt";
    downloadPage = "https://github.com/BiglySoftware/BiglyBT";
  };
})
