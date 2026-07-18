{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  caja,
  djvulibre,
  gettext,
  gitUpdater,
  glib,
  gtk-doc,
  gtk3,
  hicolor-icon-theme,
  itstool,
  libarchive,
  libgxps,
  libsecret,
  libspectre,
  libxml2,
  mate-desktop,
  pkg-config,
  poppler,
  texlive,
  webkitgtk_4_1,
  wrapGAppsHook3,
  yelp-tools,
  enableDjvu ? true,
  enableEpub ? true,
  enableImages ? false,
  enablePostScript ? true,
  enableXps ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "atril";
  version = "1.28.6";

  src = fetchFromGitHub {
    owner = "mate-desktop";
    repo = "atril";
    tag = "v${finalAttrs.version}";
    hash = "sha256-d5wkMsO3iR3qudL6JXmybDWkdvRgc53FFuf9S6wPEtU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    autoreconfHook
    gtk-doc
    itstool
    pkg-config
    gettext
    wrapGAppsHook3
    yelp-tools
  ];

  buildInputs = [
    caja
    gtk3
    glib
    libarchive
    libsecret
    libxml2
    poppler
    mate-desktop
    hicolor-icon-theme
    texlive.bin.core # for synctex, used by the pdf back-end
  ]
  ++ lib.optionals enableDjvu [ djvulibre ]
  ++ lib.optionals enableEpub [ webkitgtk_4_1 ]
  ++ lib.optionals enablePostScript [ libspectre ]
  ++ lib.optionals enableXps [ libgxps ];

  configureFlags =
    [ ]
    ++ lib.optionals enableDjvu [ "--enable-djvu" ]
    ++ lib.optionals enableEpub [
      # FIXME: We ship this with non-existent fallback mathjax-directory
      # because `MathJax.js` is only available in MathJax 2.7.x.
      "--enable-epub"
    ]
    ++ lib.optionals enablePostScript [ "--enable-ps" ]
    ++ lib.optionals enableXps [ "--enable-xps" ]
    ++ lib.optionals enableImages [ "--enable-pixbuf" ];

  makeFlags = [ "cajaextensiondir=$$out/lib/caja/extensions-2.0" ];
  env.NIX_CFLAGS_COMPILE = "-I${glib.dev}/include/gio-unix-2.0";

  postInstall = ''
    substituteInPlace $out/share/thumbnailers/atril.thumbnailer \
      --replace-fail "TryExec=atril-thumbnailer" "TryExec=$out/bin/atril-thumbnailer" \
      --replace-fail "Exec=atril-thumbnailer" "Exec=$out/bin/atril-thumbnailer"
  '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
  };

  meta = {
    description = "Simple multi-page document viewer for the MATE desktop";
    homepage = "https://mate-desktop.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})
