{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  cjson,
  curl,
  e2fsprogs,
  expat,
  fontconfig,
  freetype,
  glib,
  glibc,
  harfbuzz,
  libGL,
  libgpg-error,
  libselinux,
  libx11,
  libxcb,
  libxcrypt,
  libxcrypt-legacy,
  libxkbcommon,
  p11-kit,
  pango,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "navicat-premium";
  version = "17.3.7";

  src = appimageTools.extractType2 {
    inherit (finalAttrs) pname version;

    src =
      {
        aarch64-linux = fetchurl {
          hash = "sha256-2WOSwezm/utHaKUktrsWAfoXzCVMz+lfa1wyx0NtXMs=";
          url = "https://web.archive.org/web/20260203040711/https://dn.navicat.com/download/navicat17-premium-en-aarch64.AppImage";
        };

        x86_64-linux = fetchurl {
          hash = "sha256-bIIqDwhajE7+S/Mx7lUn3FC1ZvRbk5mwxYwsmELBlRc=";
          url = "https://web.archive.org/web/20260203040321/https://dn.navicat.com/download/navicat17-premium-en-x86_64.AppImage";
        };
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  };

  nativeBuildInputs = [
    autoPatchelfHook
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    cjson
    curl
    e2fsprogs
    expat
    fontconfig
    freetype
    glib
    glibc
    harfbuzz
    libGL
    libx11
    libgpg-error
    libselinux
    libxcb
    libxcrypt
    libxcrypt-legacy
    libxkbcommon
    p11-kit
    pango
    qt6.qtbase
  ];

  installPhase = ''
    runHook preInstall

    cp -r --no-preserve=mode usr $out
    chmod +x $out/bin/navicat
    mkdir -p $out/usr
    ln -s $out/lib $out/usr/lib

    runHook postInstall
  '';

  preFixup = ''
    rm $out/lib/libselinux.so.1
    ln -s ${libselinux.out}/lib/libselinux.so.1 $out/lib/libselinux.so.1
    rm $out/lib/glib/libglib-2.0.so.0
    ln -s ${glib.out}/lib/libglib-2.0.so.0 $out/lib/glib/libglib-2.0.so.0
    patchelf --replace-needed libcrypt.so.1 \
      ${libxcrypt}/lib/libcrypt.so.2 $out/lib/pq-g/libpq.so.5.5
    patchelf --replace-needed libcrypt.so.1 \
      ${libxcrypt}/lib/libcrypt.so.2 $out/lib/pq-g/libpq_ce.so.5.5
    patchelf --replace-needed libselinux.so.1 \
      ${libselinux.out}/lib/libselinux.so.1 $out/lib/pq-g/libpq.so.5.5
    wrapQtApp $out/bin/navicat \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          e2fsprogs
          expat
          fontconfig
          freetype
          glib
          glibc
          harfbuzz
          libGL
          libx11
          libgpg-error
          libselinux
          libxcb
          libxkbcommon
          p11-kit
          pango
        ]
      }:$out/lib \
      --set QT_PLUGIN_PATH $out/plugins \
      --set QT_QPA_PLATFORM xcb \
      --set QT_STYLE_OVERRIDE Fusion \
      --chdir $out
  '';

  autoPatchelfIgnoreMissingDeps = lib.optionals stdenv.hostPlatform.isAarch64 [
    "libgs_ktool.so"
    "libkmc.so"
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Database development tool that allows you to simultaneously connect to many databases";
    homepage = "https://www.navicat.com/products/navicat-premium";
    changelog = "https://www.navicat.com/products/navicat-premium-release-note";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "navicat-premium";
  };
})
