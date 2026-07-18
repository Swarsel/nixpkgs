{
  lib,
  stdenv,
  fetchFromGitHub,
  gdk-pixbuf,
  gettext,
  glib,
  glib-networking,
  gnutls,
  gobject-introspection,
  gpgme,
  gst_all_1,
  gtk4,
  icu,
  libadwaita,
  libcanberra,
  libgcrypt,
  libgee,
  libnice,
  libnotify,
  libomemo-c,
  libsoup_3,
  meson,
  ninja,
  pkg-config,
  qrencode,
  sqlite,
  srtp,
  vala,
  webrtc-audio-processing,
  wrapGAppsHook4,
}:

# Upstream is very deliberate about which features are enabled per default or are automatically enabled.
# Everything that is disabled per default has to been seen experimental and should not be enabled without strong reasoning.
# see https://github.com/NixOS/nixpkgs/issues/469614#issuecomment-3649662176
let
  inherit (gst_all_1)
    gstreamer
    gst-plugins-base
    ;
  gst-plugins-good = gst_all_1.gst-plugins-good.override { gtkSupport = true; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dino";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "dino";
    repo = "dino";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TgXPJP+Xm8LrO2d8yMu6aCCypuBRKNtYuZAb0dYfhng=";
  };

  postPatch = ''
    echo ${finalAttrs.version} > VERSION
  '';

  nativeBuildInputs = [
    vala
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    gettext
    gobject-introspection
  ];

  buildInputs = [
    qrencode
    glib
    glib-networking # required for TLS support
    libadwaita
    libgee
    sqlite
    gdk-pixbuf
    gtk4
    libnotify
    gpgme
    libgcrypt
    libsoup_3
    icu
    libcanberra
    libomemo-c
    srtp
    libnice
    gnutls
    gstreamer
    gst-plugins-base
    gst-plugins-good # contains rtpbin, required for VP9
    webrtc-audio-processing
  ];

  # Undefined symbols for architecture arm64: "_gpg_strerror"
  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_LDFLAGS = "-lgpg-error";
  };

  doCheck = true;

  # Dino looks for plugins with a .so filename extension, even on macOS where
  # .dylib is appropriate, and despite the fact that it builds said plugins with
  # that as their filename extension
  #
  # Therefore, on macOS rename all of the plugins to use correct names that Dino
  # will load
  #
  # See https://github.com/dino/dino/wiki/macOS
  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    cd "$out/lib/dino/plugins/"
    for f in *.dylib; do
      mv "$f" "$(basename "$f" .dylib).so"
    done
  '';

  meta = {
    description = "Modern Jabber/XMPP Client using GTK/Vala";
    homepage = "https://github.com/dino/dino";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ qyliss ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "dino";
  };
})
