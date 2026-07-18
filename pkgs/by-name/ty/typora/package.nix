{
  lib,
  stdenv,
  fetchurl,
  # dependencies
  alsa-lib,
  autoPatchelfHook,
  # runtime dependencies
  cups,
  dbus,
  dpkg,
  gtk3,
  libGL,
  libgbm,
  makeShellWrapper,
  nss,
  pango,
  undmg,
}:

let
  pname = "typora";
  version = "1.13.6";

  passthru = {
    sources = {
      aarch64-darwin = fetchurl {
        hash = "sha256-kXnzhuu3ItF9mV0x+v7+hbYNCOo1DAfIzYMHwAL+LHM=";

        urls = [
          "https://download.typora.io/mac/Typora-${version}.dmg"
          "https://downloads.typoraio.cn/mac/Typora-${version}.dmg"
        ];
      };

      aarch64-linux = fetchurl {
        hash = "sha256-3/eS9xAC7+V55grhHPLU/9+JefkXgIyKlEh3vRkqZUo=";

        urls = [
          "https://download.typora.io/linux/typora_${version}_arm64.deb"
          "https://downloads.typoraio.cn/linux/typora_${version}_arm64.deb"
        ];
      };

      x86_64-linux = fetchurl {
        hash = "sha256-EwVqMinvC26R5ULDGiiONwS3sH3GBJ/sPr2pnqfQR5s=";

        urls = [
          "https://download.typora.io/linux/typora_${version}_amd64.deb"
          "https://downloads.typoraio.cn/linux/typora_${version}_amd64.deb"
        ];
      };
    };

    updateScript = ./update.sh;
  };

  src =
    passthru.sources.${stdenv.hostPlatform.system}
      or (throw "unsupported system ${stdenv.hostPlatform.system}");

  meta = {
    description = "A minimal Markdown editor and reader.";
    homepage = "https://typora.io/";
    changelog = "https://typora.io/releases/all";
    license = lib.licenses.unfree;

    maintainers = with lib.maintainers; [
      npulidomateo
      chillcicada
    ];

    platforms = builtins.attrNames passthru.sources;
  }
  // lib.optionalAttrs stdenv.hostPlatform.isLinux {
    mainProgram = "typora";
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
      cp -a Typora.app $out/Applications

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

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      makeShellWrapper
    ];

    buildInputs = [
      alsa-lib
      nss
      gtk3
      libgbm
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,share,opt}

      cp -r usr/share/typora $out/opt
      cp -r usr/share/{applications,icons} $out/share

      sed -i '/Change Log/d' "$out/share/applications/typora.desktop"

      makeShellWrapper $out/opt/typora/Typora $out/bin/typora \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL ]}"

      runHook postInstall
    '';

    runtimeDependencies = map lib.getLib [
      cups
      dbus
      pango
    ];
  }
