{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  exempi,
  gettext,
  gitUpdater,
  gnome,
  gtk-doc,
  gtk3,
  hicolor-icon-theme,
  itstool,
  lcms2,
  libavif,
  libexif,
  libheif,
  libjpeg,
  libjxl,
  libpeas,
  librsvg,
  libxml2,
  mate-common,
  mate-desktop,
  pkg-config,
  shared-mime-info,
  webp-pixbuf-loader,
  wrapGAppsHook3,
  yelp-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "eom";
  version = "1.28.1";

  src = fetchFromGitHub {
    owner = "mate-desktop";
    repo = "eom";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2MO8z30Styv5vAnNVFpETAZtZ+LMbgBSDq1mUQZ9X1c=";
  };

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    gtk-doc
    mate-common # mate-common.m4 macros
    pkg-config
    gettext
    itstool
    wrapGAppsHook3
    yelp-tools
  ];

  buildInputs = [
    exempi
    lcms2
    libexif
    libjpeg
    librsvg
    libxml2
    shared-mime-info
    gtk3
    libpeas
    mate-desktop
    hicolor-icon-theme
  ];

  postInstall = ''
    # In postInstall to run before gappsWrapperArgsHook.
    export GDK_PIXBUF_MODULE_FILE="${
      gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
        extraLoaders = [
          libavif
          libheif.lib
          libjxl
          librsvg
          webp-pixbuf-loader
        ];
      }
    }"
  '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
  };

  meta = {
    description = "Image viewing and cataloging program for the MATE desktop";
    homepage = "https://mate-desktop.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "eom";
    teams = [ lib.teams.mate ];
  };
})
