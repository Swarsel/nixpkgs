{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  glib,
  gtk3,
  jdk,
  jre,
  libxtst,
  makeWrapper,
  swt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ipscan";
  version = "3.9.3";

  src = fetchurl {
    url = "https://github.com/angryip/ipscan/releases/download/${finalAttrs.version}/ipscan_${finalAttrs.version}_amd64.deb";
    hash = "sha256-RLdlcrtpWcO4z7cKSN+y9UJzMBtnli2mAvuJSXCMoJU=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  buildInputs = [ jdk ];

  installPhase = ''
    mkdir -p $out/share
    cp usr/lib/ipscan/ipscan-linux64-${finalAttrs.version}.jar $out/share/${finalAttrs.pname}-${finalAttrs.version}.jar

    makeWrapper ${jre}/bin/java $out/bin/ipscan \
      --prefix LD_LIBRARY_PATH : "$out/lib/:${
        lib.makeLibraryPath [
          swt
          libxtst
          gtk3
          glib
        ]
      }" \
      --add-flags "-Xmx256m -cp $out/share/${finalAttrs.pname}-${finalAttrs.version}.jar:${swt}/jars/swt.jar net.azib.ipscan.Main"

    install -D usr/share/applications/ipscan.desktop -t $out/share/applications/
    substituteInPlace $out/share/applications/ipscan.desktop --replace-fail "Exec=sh /usr/bin/ipscan" "Exec=ipscan"
    install -D usr/share/pixmaps/ipscan.png -t $out/share/icons/hicolor/128x128/apps
  '';

  meta = {
    description = "Angry IP Scanner - fast and friendly network scanner";
    homepage = "https://angryip.org";
    changelog = "https://github.com/angryip/ipscan/blob/${finalAttrs.version}/CHANGELOG";
    license = lib.licenses.gpl2Only;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      kylesferrazza
      totoroot
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "ipscan";
    downloadPage = "https://github.com/angryip/ipscan/releases/tag/${finalAttrs.version}";
  };
})
