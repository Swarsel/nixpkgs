{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream,
  blueprint-compiler,
  desktop-file-utils,
  gettext,
  glib,
  glib-networking,
  gnome,
  gobject-introspection,
  gst_all_1,
  gtk4,
  libadwaita,
  libavif,
  libheif,
  librsvg,
  libsecret,
  meson,
  ninja,
  pkg-config,
  python3,
  python3Packages,
  webp-pixbuf-loader,
  wrapGAppsHook4,
  xdg-user-dirs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nocturne";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "Jeffser";
    repo = "Nocturne";
    tag = finalAttrs.version;
    hash = "sha256-uXsl438K0Ew0fdrKtGf28VkHQ76loDWKLJkounzqhEQ=";
  };

  # avoid installing Navidrome at runtime if not available, incompatible with the nix store
  patches = [ ./disable-navidrome-setup.patch ];
  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    blueprint-compiler
    gobject-introspection
    wrapGAppsHook4
    gettext # for msgfmt
    desktop-file-utils # for desktop-file-validate
    appstream
    glib
    pkg-config
    gtk4
    python3
  ];

  buildInputs = [
    gtk4
    libadwaita
    libsecret
    python3
    glib-networking
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  preInstall = ''
    export GDK_PIXBUF_MODULE_FILE="${
      gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
        extraLoaders = [
          librsvg
          webp-pixbuf-loader
          libavif
          libheif.lib
        ];
      }
    }"
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ xdg-user-dirs ]}
      --prefix PYTHONPATH : ${python3.pkgs.makePythonPath finalAttrs.pythonDependencies}
    )
  '';

  __structuredAttrs = true;
  dontUseCmakeConfigure = true;

  pythonDependencies = [
    python3Packages.pygobject3
    python3Packages.tinytag
    python3Packages.requests
    python3Packages.syncedlyrics
    python3Packages.pycairo
    python3Packages.colorthief
    python3Packages.mpris-server
    python3Packages.pillow
  ];

  meta = {
    description = "Adwaita music player for OpenSubsonic servers like Navidrome";
    homepage = "https://jeffser.com/nocturne/";
    changelog = "https://github.com/Jeffser/Nocturne/releases";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ pbsds ];
    platforms = lib.platforms.linux;
    mainProgram = "nocturne";
  };
})
