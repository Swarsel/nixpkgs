{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  atk,
  bzip2,
  cairo,
  copyDesktopItems,
  dbus,
  gdk-pixbuf,
  glib,
  gst_all_1,
  gtk3,
  libaom,
  libayatana-appindicator,
  libgit2,
  libopus,
  libpulseaudio,
  libsciter,
  libsodium,
  libvpx,
  libxkbcommon,
  libxtst,
  libyuv,
  makeDesktopItem,
  openssl,
  pam,
  pango,
  perl,
  pkg-config,
  rustPlatform,
  wrapGAppsHook3,
  xdotool,
  zlib,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rustdesk";
  version = "1.4.9";

  src = fetchFromGitHub {
    owner = "rustdesk";
    repo = "rustdesk";
    tag = finalAttrs.version;
    hash = "sha256-AnwdIO4TveC48uMioBCvH60xun24ckK420ONSEB9lQI=";
    fetchSubmodules = true;
  };

  patches = [
    ./make-build-reproducible.patch
  ];

  postPatch = ''
    sed -e '1i #include <cstdint>' -i $cargoDepsCopy/*/webm-1.1.0/src/sys/libwebm/mkvparser/mkvparser.cc
    sed -e '1i #include <cstdint>' -i $cargoDepsCopy/*/webm-sys-1.0.4/libwebm/mkvparser/mkvparser.cc
  '';

  nativeBuildInputs = [
    copyDesktopItems
    perl
    pkg-config
    rustPlatform.bindgenHook
    wrapGAppsHook3
  ];

  buildInputs = [
    atk
    bzip2
    cairo
    dbus
    gdk-pixbuf
    glib
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    gtk3
    libgit2
    libpulseaudio
    libsodium
    libxtst
    libvpx
    libyuv
    libopus
    libaom
    libxkbcommon
    openssl
    pam
    pango
    zlib
    zstd
  ]

  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    xdotool
  ];

  cargoHash = "sha256-HPvvsTcjSErGfdNwsHgWhs930Fe0hmK1g5J/ngtlkKM=";

  env = {
    SODIUM_USE_PKG_CONFIG = true;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  # Checks require an active X server
  doCheck = false;

  # Add static ui resources and libsciter to same folder as binary so that it
  # can find them.
  postInstall = ''
    mkdir -p $out/{share/src,lib/rustdesk}

    # .so needs to be next to the executable
    mv $out/bin/rustdesk $out/lib/rustdesk
    ${lib.optionalString stdenv.hostPlatform.isLinux "ln -s ${libsciter}/lib/libsciter-gtk.so $out/lib/rustdesk"}

    makeWrapper $out/lib/rustdesk/rustdesk $out/bin/rustdesk \
      --chdir "$out/share"

    cp -a $src/src/ui $out/share/src

    install -Dm0644 $src/res/logo.svg $out/share/icons/hicolor/scalable/apps/rustdesk.svg
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-rpath "${libayatana-appindicator}/lib" "$out/lib/rustdesk/rustdesk"
  '';

  __structuredAttrs = true;
  buildFeatures = lib.optionals stdenv.hostPlatform.isLinux [ "linux-pkg-config" ];

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Network" ];
      comment = finalAttrs.meta.description;
      desktopName = "RustDesk";
      exec = finalAttrs.meta.mainProgram;
      genericName = "Remote Desktop";
      icon = "rustdesk";
      mimeTypes = [ "x-scheme-handler/rustdesk" ];
      name = "rustdesk";
    })
  ];

  meta = {
    description = "Virtual / remote desktop infrastructure for everyone! Open source TeamViewer / Citrix alternative";
    homepage = "https://rustdesk.com";
    changelog = "https://github.com/rustdesk/rustdesk/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      ocfox
      leixb
    ];

    badPlatforms = lib.platforms.darwin;
    mainProgram = "rustdesk";
  };
})
