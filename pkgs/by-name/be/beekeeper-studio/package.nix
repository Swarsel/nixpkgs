{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  autoPatchelfHook,
  cairo,
  cups,
  dbus,
  dpkg,
  expat,
  gcc,
  gdk-pixbuf,
  glib,
  glibc,
  gtk3,
  krb5,
  libGL,
  libdrm,
  libgbm,
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
  runtimeShell,
  systemd,
  unzip,
  vulkan-loader,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "beekeeper-studio";
  version = "5.8.1";

  src =
    let
      selectSystem = attrs: attrs.${stdenv.hostPlatform.system};
      asset = selectSystem {
        aarch64-darwin = "Beekeeper-Studio-${finalAttrs.version}-arm64-mac.zip";
        aarch64-linux = "beekeeper-studio_${finalAttrs.version}_arm64.deb";
        x86_64-linux = "beekeeper-studio_${finalAttrs.version}_amd64.deb";
      };
    in
    fetchurl {
      url = "https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v${finalAttrs.version}/${asset}";

      hash = selectSystem {
        aarch64-darwin = "sha256-Jnm4Vfm9+6dXmjnI5gYpYW1g7Anl9xhIKXbQA2SGUDE=";
        aarch64-linux = "sha256-iuZDeSYljiSRUqtLIA1BcrRaYoqg9dnlbRDLsetVkMQ=";
        x86_64-linux = "sha256-e5y7uBzdbDSUQKpxRjho+2kU3wx23spdSv1PwmJ30gA=";
      };
    };

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      dpkg
      autoPatchelfHook
      makeWrapper
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ unzip ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    (lib.getLib stdenv.cc.cc)
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxkbcommon
    glibc
    gcc
    libGL
    glib
    gtk3
    pango
    cairo
    dbus
    at-spi2-atk
    cups
    libdrm
    gdk-pixbuf
    nss
    nspr
    alsa-lib
    expat
    libgbm
    vulkan-loader
    krb5
  ];

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    cp -r usr $out
    substituteInPlace $out/share/applications/beekeeper-studio.desktop \
      --replace-fail '"/opt/Beekeeper Studio/beekeeper-studio"' "beekeeper-studio"
    mkdir -p $out/opt $out/bin
    cp -r opt/"Beekeeper Studio" $out/opt/beekeeper-studio
    makeWrapper $out/opt/beekeeper-studio/beekeeper-studio-bin $out/bin/beekeeper-studio \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p "$out/Applications" "$out/bin"
    cp -R . "$out/Applications/Beekeeper Studio.app"
    # Create a launcher script to run from the command line
    cat > "$out/bin/beekeeper-studio" << EOF
    #!${runtimeShell}
    open -na "$out/Applications/Beekeeper Studio.app" --args "\$@"
    EOF
    chmod +x "$out/bin/beekeeper-studio"
  ''
  + ''
    runHook postInstall
  '';

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-needed libGL.so.1 \
      --add-needed libEGL.so.1 \
      --add-rpath ${
        lib.makeLibraryPath [
          libGL
        ]
      } $out/opt/beekeeper-studio/beekeeper-studio-bin
  '';

  dontFixup = stdenv.hostPlatform.isDarwin;
  runtimeDependencies = lib.optionals stdenv.hostPlatform.isLinux (lib.getLib systemd);
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Modern and easy to use SQL client for MySQL, Postgres, SQLite, SQL Server, and more";
    homepage = "https://www.beekeeperstudio.io";
    changelog = "https://github.com/beekeeper-studio/beekeeper-studio/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      milogert
      alexnortung
      iamanaws
    ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "beekeeper-studio";
  };
})
