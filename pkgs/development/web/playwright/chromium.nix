{
  lib,
  stdenv,
  alsa-lib,
  at-spi2-atk,
  atk,
  autoPatchelfHook,
  browserVersion,
  cairo,
  chromium,
  cups,
  dbus,
  expat,
  fetchzip,
  fontconfig_file,
  glib,
  gobject-introspection,
  libGL,
  libgbm,
  libgcc,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  makeWrapper,
  nspr,
  nss,
  pango,
  patchelf,
  pciutils,
  revision,
  runCommand,
  system,
  systemd,
  throwSystem,
  vulkan-loader,
  ...
}:
let
  download =
    (import ./browser-downloads.nix {
      inherit revision browserVersion;
      name = "chromium";
    }).${system} or throwSystem;

  # Playwright expects different directory names for different architectures:
  # - linux-x64 expects: chrome-linux64
  # - linux-arm64 expects: chrome-linux
  chromeDir =
    {
      aarch64-linux = "chrome-linux";
      x86_64-linux = "chrome-linux64";
    }
    .${system} or throwSystem;

  chromium-linux = stdenv.mkDerivation {
    src = fetchzip {
      inherit (download) url stripRoot;

      hash =
        {
          aarch64-linux = "sha256-5vNF1/utXGctixYJj/0qvi6X0qklIG9XCcet94feQoA=";
          x86_64-linux = "sha256-/0OwT0Asm4A/rUkFruw1JYWbDInFJPuDX0CEdNjeMLo=";
        }
        .${system} or throwSystem;
    };

    nativeBuildInputs = [
      autoPatchelfHook
      patchelf
      makeWrapper
    ];

    buildInputs = [
      alsa-lib
      at-spi2-atk
      atk
      cairo
      cups
      dbus
      expat
      glib
      gobject-introspection
      libgbm
      libgcc
      libxkbcommon
      nspr
      nss
      pango
      stdenv.cc.cc.lib
      systemd
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxcb
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/${chromeDir}
      cp -R . $out/${chromeDir}

      wrapProgram $out/${chromeDir}/chrome \
        --set-default SSL_CERT_FILE /etc/ssl/certs/ca-bundle.crt \
        --set-default FONTCONFIG_FILE ${fontconfig_file}

      runHook postInstall
    '';

    postFixup = ''
      # replace bundled vulkan-loader since we are also already adding our own to RPATH
      rm "$out/${chromeDir}/libvulkan.so.1"
      ln -s -t "$out/${chromeDir}" "${lib.getLib vulkan-loader}/lib/libvulkan.so.1"
    '';

    appendRunpaths = lib.makeLibraryPath [
      libGL
      vulkan-loader
      pciutils
    ];

    name = "playwright-chromium";
  };
  chromium-darwin = fetchzip {
    inherit (download) url stripRoot;

    hash =
      {
        aarch64-darwin = "sha256-aJbvZQ1hY0FfDC+ZktfW2yNW3nwc0kh/P30+n/cmLf0=";
      }
      .${system} or throwSystem;
  };
in
{
  aarch64-darwin = chromium-darwin;
  aarch64-linux = chromium-linux;
  x86_64-linux = chromium-linux;
}
.${system} or throwSystem
