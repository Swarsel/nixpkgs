{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  jre,
  makeDesktopItem,
  runtimeShell,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zap";
  version = "2.17.0";

  src = fetchurl {
    url = "https://github.com/zaproxy/zaproxy/releases/download/v${finalAttrs.version}/ZAP_${finalAttrs.version}_Linux.tar.gz";
    hash = "sha256-7+eZqqNifbaDtD8AycIQrqC3XADMjwoPBDTRK7Pd3lo=";
  };

  nativeBuildInputs = [ copyDesktopItems ];
  buildInputs = [ jre ];

  # Copying config and adding version tag before first use to avoid permission
  # issues if zap tries to copy config on it's own.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share}

    cp -pR . "$out/share/zap/"

    cat >> "$out/bin/zap" << EOF
    #!${runtimeShell}
    export PATH="${lib.makeBinPath [ jre ]}:\$PATH"
    export JAVA_HOME='${jre}'
    if ! [ -f "\$HOME/.ZAP/config.xml" ];then
      mkdir -p "\$HOME/.ZAP"
      head -n 2 $out/share/zap/xml/config.xml > "\$HOME/.ZAP/config.xml"
      echo "<version>${finalAttrs.version_tag}</version>" >> "\$HOME/.ZAP/config.xml"
      tail -n +3 $out/share/zap/xml/config.xml >> "\$HOME/.ZAP/config.xml"
    fi
    exec "$out/share/zap/zap.sh"  "\$@"
    EOF

    chmod u+x  "$out/bin/zap"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Development"
        "Security"
        "System"
      ];

      desktopName = "Zed Attack Proxy";
      exec = "zap";
      icon = "zap";
      name = "zap";
    })
  ];

  # From https://github.com/zaproxy/zaproxy/blob/master/zap/src/main/java/org/parosproxy/paros/Constant.java
  version_tag = "20012000";

  meta = {
    description = "Java application for web penetration testing";
    homepage = "https://www.zaproxy.org/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      mog
      rafael
    ];

    platforms = lib.platforms.linux;
    mainProgram = "zap";
  };
})
