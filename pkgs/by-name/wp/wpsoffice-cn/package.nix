{
  lib,
  stdenv,
  fetchurl,
  # wpsoffice dependencies
  alsa-lib,
  autoPatchelfHook,
  cacert,
  coreutils,
  # wpsoffice runtime dependencies
  cups,
  curl,
  dbus,
  gtk3,
  libgbm,
  libjpeg,
  libmysqlclient,
  libsForQt5,
  libtool,
  libusb1,
  libxdamage,
  libxkbcommon,
  libxtst,
  libxv,
  nspr,
  pango,
  runCommandLocal,
  udev,
  undmg,
  unixodbc,
}:

let
  pname = "wpsoffice-cn";
  sources = import ./sources.nix;
  version = if stdenv.hostPlatform.isDarwin then sources.darwin-version else sources.linux-version;

  fetch =
    if stdenv.hostPlatform.isDarwin then
      fetchurl
    else
      {
        hash,
        url,
      }:
      runCommandLocal "wpsoffice-cn-${version}.deb"
        {
          nativeBuildInputs = [
            curl
            coreutils
          ];

          SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
          impureEnvVars = lib.fetchers.proxyImpureEnvVars;
          outputHash = hash;
          outputHashAlgo = "sha256";
        }
        ''
          readonly SECURITY_KEY="7f8faaaa468174dc1c9cd62e5f218a5b"

          timestamp10=$(date '+%s')
          md5hash=($(printf '%s' "$SECURITY_KEY${lib.removePrefix "https://wps-linux-personal.wpscdn.cn" url}$timestamp10" | md5sum))

          curl --retry 3 --retry-delay 3 "${url}?t=$timestamp10&k=$md5hash" > $out
        '';

  src =
    fetch
      sources.${stdenv.hostPlatform.system}
        or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  passthru = {
    updateScript = ./update.sh;
  };

  meta = {
    description = "Office suite, formerly Kingsoft Office";
    homepage = "https://www.wps.cn";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      mlatus
      th0rgal
      wineee
      pokon548
      chillcicada
    ];

    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];

    hydraPlatforms = [ ];
  }
  // lib.optionalAttrs stdenv.hostPlatform.isLinux {
    changelog = "https://linux.wps.cn/wpslinuxlog";
    mainProgram = "wps";
  };
in

if stdenv.hostPlatform.isDarwin then
  stdenv.mkDerivation {
    inherit
      pname
      version
      src
      passthru
      meta
      ;

    nativeBuildInputs = [ undmg ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -a wpsoffice.app $out/Applications

      runHook postInstall
    '';

    sourceRoot = ".";
  }

else
  stdenv.mkDerivation {
    inherit
      pname
      version
      src
      passthru
      meta
      ;

    nativeBuildInputs = [ autoPatchelfHook ];

    buildInputs = [
      alsa-lib
      libjpeg
      libtool
      libxkbcommon
      nspr
      udev
      gtk3
      libgbm
      libusb1
      unixodbc
      libsForQt5.qtbase
      libxdamage
      libxtst
      libxv
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out

      cp -r opt $out
      cp -r usr/{bin,share} $out

      for i in $out/bin/*; do
        substituteInPlace $i \
          --replace-fail /opt/kingsoft/wps-office $out/opt/kingsoft/wps-office
      done

      for i in $out/share/applications/*; do
        substituteInPlace $i \
          --replace-fail /usr/bin/ ""
      done

      runHook postInstall
    '';

    preFixup = ''
      # dlopen dependency
      patchelf --add-needed libudev.so.1 $out/opt/kingsoft/wps-office/office6/addons/cef/libcef.so
      # libmysqlclient dependency
      patchelf --replace-needed libmysqlclient.so.18 libmysqlclient.so $out/opt/kingsoft/wps-office/office6/libFontWatermark.so
      patchelf --add-rpath ${libmysqlclient}/lib/mariadb $out/opt/kingsoft/wps-office/office6/libFontWatermark.so
    '';

    dontWrapQtApps = true;

    runtimeDependencies = map lib.getLib [
      cups
      dbus
      pango
    ];

    stripAllList = [ "opt" ];

    unpackPhase = ''
      # Unpack the .deb file
      ar x $src
      tar -xf data.tar.xz

      # Remove unneeded files
      rm -rf usr/share/{fonts,locale,templates}
      rm -f usr/bin/misc
      rm -rf opt/kingsoft/wps-office/{desktops,INSTALL,templates}
      rm -f opt/kingsoft/wps-office/office6/lib{peony-wpsprint-menu-plugin,bz2,jpeg,stdc++,gcc_s,odbc*,dbus-1}.so*
    '';
  }
