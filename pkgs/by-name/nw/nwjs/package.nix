{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-core,
  atk,
  autoPatchelfHook,
  buildEnv,
  buildPackages,
  cairo,
  cups,
  dbus,
  expat,
  ffmpeg,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libcap,
  libdrm,
  libgbm,
  libnotify,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  makeWrapper,
  nspr,
  nss,
  pango,
  sqlite,
  systemd,
  udev,
  sdk ? false,
}:

let
  bits = if stdenv.hostPlatform.is64bit then "x64" else "ia32";

  nwEnv = buildEnv {
    extraOutputsToInstall = [
      "lib"
      "out"
    ];

    name = "nwjs-env";

    paths = [
      alsa-lib
      at-spi2-core
      atk
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libcap
      libdrm
      libGL
      libnotify
      libxkbcommon
      libgbm
      nspr
      nss
      pango
      libx11
      libxscrnsaver
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxtst
      libxshmfence
      # libnw-specific (not chromium dependencies)
      ffmpeg
      libxcb
      # chromium runtime deps (dlopen’d)
      libuuid
      sqlite
      udev
    ];
  };

  version = "0.102.1";
in
stdenv.mkDerivation {
  inherit version;
  pname = "nwjs";

  src =
    let
      flavor = if sdk then "sdk-" else "";
    in
    fetchurl {
      url = "https://dl.nwjs.io/v${version}/nwjs-${flavor}v${version}-linux-${bits}.tar.gz";

      # TODO: Write an update script to update all 4 hashes.
      # nixpkgs-update: no auto update
      hash =
        {
          "ia32" = "sha256-oODdSKNlOPSLD9vAqRwYcAgH6mumyOB5Fp6G9ifSgok=";
          "sdk-ia32" = "sha256-uzDbEq2vNC+fm95Co3lnQX7mrUXsIDWFoa0osWCn3EM=";
          "sdk-x64" = "sha256-jWw5kXYGxu7oen8fK2Q58QPhiBRC6H2ibGXkeUFW2pI=";
          "x64" = "sha256-WhHV+xj2ngEz+i1ipBhwZD9b0EF/hdi8gMBZw5qYRGA=";
        }
        ."${flavor + bits}";
    };

  nativeBuildInputs = [
    autoPatchelfHook
    # override doesn't preserve splicing https://github.com/NixOS/nixpkgs/issues/132651
    # Has to use `makeShellWrapper` from `buildPackages` even though `makeShellWrapper` from the inputs is spliced because `propagatedBuildInputs` would pick the wrong one because of a different offset.
    (buildPackages.wrapGAppsHook3.override { makeWrapper = buildPackages.makeShellWrapper; })
  ];

  buildInputs = [ nwEnv ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/nwjs
    cp -R * $out/share/nwjs
    find $out/share/nwjs

    ln -s ${lib.getLib systemd}/lib/libudev.so $out/share/nwjs/libudev.so.0

    mkdir -p $out/bin
    ln -s $out/share/nwjs/nw $out/bin

    mkdir $out/lib
    ln -s $out/share/nwjs/lib/libnw.so $out/lib/libnw.so

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
    )
  '';

  appendRunpaths = map (pkg: (lib.getLib pkg) + "/lib") [
    nwEnv
    stdenv.cc.libc
    stdenv.cc.cc
  ];

  meta = {
    description = "App runtime based on Chromium and node.js";
    homepage = "https://nwjs.io/";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.mikaelfangel ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "nw";
  };
}
