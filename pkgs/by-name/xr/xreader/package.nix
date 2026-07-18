{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  djvulibre,
  glib,
  gobject-introspection,
  gtk3,
  intltool,
  libarchive,
  libgxps,
  libsecret,
  libspectre,
  libxml2,
  mathjax,
  meson,
  ninja,
  pkg-config,
  poppler,
  shared-mime-info,
  webkitgtk_4_1,
  wrapGAppsHook3,
  xapp,
  xapp-symbolic-icons,
  backends ? [
    "pdf"
    "ps" # "dvi" "t1lib"
    "djvu"
    "tiff"
    "pixbuf"
    "comics"
    "xps"
    "epub"
  ],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xreader";
  version = "4.6.5";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "xreader";
    rev = finalAttrs.version;
    hash = "sha256-wycQmScxuSlo6Ln6piSBF7kmzvi6FnTm/ES/Ds+/h8I=";
  };

  nativeBuildInputs = [
    shared-mime-info
    wrapGAppsHook3
    meson
    ninja
    pkg-config
    gobject-introspection
    intltool
  ];

  buildInputs = [
    glib
    gtk3
    xapp
    cairo
    libarchive
    libxml2
    libsecret
    poppler
    libspectre
    libgxps
    webkitgtk_4_1
    mathjax
    djvulibre
  ];

  mesonFlags = [
    # FIXME: `MathJax.js` is only available in MathJax 2.7.x.
    "-Dmathjax-directory=${mathjax}"
    "-Dintrospection=true"
  ]
  ++ (map (x: "-D${x}=true") backends);

  postInstall = ''
    substituteInPlace $out/share/thumbnailers/xreader.thumbnailer \
      --replace-fail "TryExec=xreader-thumbnailer" "TryExec=$out/bin/xreader-thumbnailer" \
      --replace-fail "Exec=xreader-thumbnailer" "Exec=$out/bin/xreader-thumbnailer"
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${lib.makeSearchPath "share" [ xapp-symbolic-icons ]}"
    )
  '';

  meta = {
    description = "Document viewer capable of displaying multiple and single page
document formats like PDF and Postscript";

    homepage = "https://github.com/linuxmint/xreader";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})
