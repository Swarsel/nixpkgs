{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  buildFHSEnv,
  dbus-glib,
  dpkg,
  gtk2,
  libxdamage,
  libxscrnsaver,
  libxtst,
  nss,
  writeShellScript,
  zenity,
}:

let
  sources = import ./sources.nix;

  xunlei-unwrapped = stdenv.mkDerivation rec {
    pname = "xunlei-uos";
    version = sources.version;

    src =
      {
        aarch64-linux = fetchurl {
          hash = sources.arm64_hash;
          url = sources.arm64_url;
        };

        loongarch64-linux = fetchurl {
          hash = sources.loongarch64_hash;
          url = sources.loongarch64_url;
        };

        x86_64-linux = fetchurl {
          hash = sources.amd64_hash;
          url = sources.amd64_url;
        };
      }
      .${stdenv.hostPlatform.system}
        or (throw "${pname}-${version}: ${stdenv.hostPlatform.system} is unsupported.");

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
    ];

    buildInputs = [
      nss
      gtk2
      alsa-lib
      dbus-glib
      libxtst
      libxdamage
      libxscrnsaver
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      cp -r opt/apps/com.xunlei.download/files $out/lib/xunlei
      cp -r opt/apps/com.xunlei.download/entries $out/share
      mv $out/share/icons/hicolor/scalable/apps/com.thunder.download.svg \
        $out/share/icons/hicolor/scalable/apps/com.xunlei.download.svg
      substituteInPlace $out/share/applications/com.xunlei.download.desktop \
        --replace-fail "Categories=net" "Categories=Network" \
        --replace-fail "/opt/apps/com.xunlei.download/files/start.sh" "xunlei-uos" \
        --replace-fail "/opt/apps/com.xunlei.download/entries/icons/hicolor/256x256/apps/com.xunlei.download.png" "com.xunlei.download"

      runHook postInstall
    '';

    meta = {
      description = "Download manager supporting HTTP, FTP, BitTorrent, and eDonkey network protocols";
      homepage = "https://www.xunlei.com";
      license = lib.licenses.unfree;
      maintainers = [ lib.maintainers.linuxwhata ];

      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "loongarch64-linux"
      ];
    };
  };
in
buildFHSEnv {
  inherit (xunlei-unwrapped) pname version meta;

  extraInstallCommands = ''
    mkdir -p $out
    ln -s ${xunlei-unwrapped}/share $out/share
  '';

  includeClosures = true;

  runScript = writeShellScript "xunlei-launcher" ''
    exec ${xunlei-unwrapped}/lib/xunlei/thunder -start $1 "$@"
  '';

  targetPkgs = pkgs: [ zenity ]; # system tray click events
  passthru.updateScript = ./update.sh;
}
