{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream,
  blueprint-compiler,
  cargo,
  clapper-enhancers,
  clapper-unwrapped,
  desktop-file-utils,
  gettext,
  glib,
  glib-networking,
  gnome,
  gst_all_1,
  gtk4,
  libadwaita,
  libheif,
  libjxl,
  librsvg,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  sqlite,
  webp-pixbuf-loader,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pipeline";
  version = "4.0.4";

  src = fetchFromGitLab {
    owner = "schmiddi-on-mobile";
    repo = "pipeline";
    tag = finalAttrs.version;
    hash = "sha256-KVAgUAQqnpzNXpCiPZJMQEVGrz/pt8fR/JcOFBynFCs=";
  };

  nativeBuildInputs = [
    meson
    ninja
    cargo
    gettext
    rustPlatform.cargoSetupHook
    rustc
    pkg-config
    wrapGAppsHook4
    glib
    appstream
    desktop-file-utils
    blueprint-compiler
  ];

  buildInputs = [
    gtk4
    libadwaita
    openssl
    sqlite
    clapper-unwrapped
    clapper-enhancers
    gst_all_1.gstreamer
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    glib-networking # For GIO_EXTRA_MODULES. Fixes "TLS support is not available"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
       --set GDK_PIXBUF_MODULE_FILE ${
         gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
           extraLoaders = [
             libjxl
             librsvg
             webp-pixbuf-loader
             libheif.lib
           ];
         }
       }
       --set CLAPPER_ENHANCERS_PATH ${clapper-enhancers}/${clapper-enhancers.passthru.pluginPath}
    )
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src pname version;
    hash = "sha256-bWMTZrcdYRXsKWD3VmLcAu9J/y9LbZ6EPE8AuB87iKA=";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Watch YouTube and PeerTube videos in one place";
    homepage = "https://mobile.schmidhuberj.de/pipeline";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      chuangzhu
      Kladki
    ];

    platforms = lib.platforms.linux;
    mainProgram = "tubefeeder";
  };
})
